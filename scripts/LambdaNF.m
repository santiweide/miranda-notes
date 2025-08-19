|| ===============================
|| Untyped lambda-calculus in Miranda
|| β + δ (arithmetic) reductions to full normal form
|| Normal-order strategy; capture-avoiding substitution.
|| ===============================

|| ---------- Names & Terms ----------

name == [char]

|| ---------- Utilities on names ----------
remove_all :: * -> [*] -> [*]
remove_all x []     = []
remove_all x (y:ys) = remove_all x ys, if x=y
                    = y : remove_all x ys, otherwise

elemN :: name -> [name] -> bool
elemN x []     = False
elemN x (y:ys) = x = y \/ elemN x ys

unionN :: [name] -> [name] -> [name]
unionN xs []      = xs
unionN xs (y:ys)  = unionN xs ys,      if elemN y xs
                  = unionN (y : xs) ys, otherwise


|| ---------- Free variables ----------
free :: term -> [name]
free (Var x)     = [x]
free (Lam x b)   = remove_all x (free b)
free (App t u)   = unionN (free t) (free u)
free (Num x)     = []
free (Add a b)   = unionN (free a) (free b)
free (Sub a b)   = unionN (free a) (free b)
free (Mul a b)   = unionN (free a) (free b)
free (Div a b)   = unionN (free a) (free b)


term ::= Var name | Lam name term
            | App term term | Num num
            | Add term term
            | Sub term term
            | Mul term term
            | Div term term

|| optional Maybe type
maybe * ::= Nothing | Just *


|| ---------- Fresh-name generation ----------
freshen :: name -> [name] -> name
freshen x avoid = freshen (x ++ "'") avoid, if elemN x avoid
                = x, otherwise

|| ---------- Rename occurrences bound by a specific binder ----------
rename_bound :: name -> name -> term -> term
rename_bound y yy t = rename_bound2 y yy 0 t

rename_bound2 :: name -> name -> num -> term -> term
rename_bound2 y yy d (Var v)   = Var yy, if v=y & d=0
                               = Var v,  otherwise
rename_bound2 y yy d (Lam v b) = Lam v (rename_bound2 y yy d1 b)
                                    where
                                        d1 = d + 1, if v = y
                                            = d,     otherwise

rename_bound2 y yy d (App t u) = App (rename_bound2 y yy d t) (rename_bound2 y yy d u)
rename_bound2 y yy d (Num n)   = Num n
rename_bound2 y yy d (Add a b) = Add (rename_bound2 y yy d a) (rename_bound2 y yy d b)
rename_bound2 y yy d (Sub a b) = Sub (rename_bound2 y yy d a) (rename_bound2 y yy d b)
rename_bound2 y yy d (Mul a b) = Mul (rename_bound2 y yy d a) (rename_bound2 y yy d b)
rename_bound2 y yy d (Div a b) = Div (rename_bound2 y yy d a) (rename_bound2 y yy d b)


|| ---------- Capture-avoiding substitution ----------
|| subst body x s   ≡   body[x := s]

subst :: term -> name -> term -> term
subst (Var y)     x s = s,  if y = x
                      = Var y, otherwise
subst (App t u)   x s = App (subst t x s) (subst u x s)
subst (Num n)     x s = Num n
subst (Add a b)   x s = Add (subst a x s) (subst b x s)
subst (Sub a b)   x s = Sub (subst a x s) (subst b x s)
subst (Mul a b)   x s = Mul (subst a x s) (subst b x s)
subst (Div a b)   x s = Div (subst a x s) (subst b x s)

subst (Lam y b)   x s = Lam y b,                     if y = x
                    = Lam y (subst b x s),       if ~elemN y (free s)
                    = Lam yy (subst bb x s),     otherwise
                            where
                                avoid = unionN (free b) (free s)   || :: [name]
                                yy    = freshen y avoid            || :: name
                                bb    = rename_bound y yy b        || :: term


|| ---------- One-step δ (arithmetic) helpers ----------

deltaAdd (Num m) (Num n) = Just (Num (m + n))
deltaAdd x y     = Nothing

deltaSub (Num m) (Num n) = Just (Num (m - n))
deltaSub x y     = Nothing

deltaMul (Num m) (Num n) = Just (Num (m * n))
deltaMul x y     = Nothing

deltaDiv (Num m) (Num n) = Just (Num (m / n))
deltaDiv x y     = Nothing

isJust (Just xs) = True
isJust x = False

fromJust (Just x) = x


|| ---------- One-step normal-order reduction (β ∪ δ) ----------

step :: term -> maybe term

|| β-redex at the outermost application
step (App (Lam x b) a) = Just (subst b x a)

|| Applications: reduce left first; if stuck, reduce right
step (App u v) = Just (App (fromJust su) v), if isJust su 
                = Just (App u (fromJust sv)), if isJust sv 
                = Nothing, otherwise
                    where
                        su = step u
                        sv = step v

|| Reduce under lambda only when nothing outer applies (normal order)
step (Lam x b) = Just (Lam x (fromJust sb)), if isJust sb
                = Nothing, otherwise
                    where
                        sb = step b

|| δ for arithmetic nodes (outermost), otherwise push inside left-to-right
step (Add a b) = dab, if isJust dab
    = Just (Add (fromJust sa) b), if isJust sa
    = Just (Add a (fromJust sb)), if isJust sb 
    = Nothing, otherwise
                    where
                        dab = deltaAdd a b
                        sa  = step a
                        sb  = step b

step (Sub a b) = dsb, if isJust dsb
               = Just (Sub (fromJust sa) b), if isJust sa
               = Just (Sub a (fromJust sb)), if isJust sb
               = Nothing, otherwise
                 where
                   dsb = deltaSub a b
                   sa  = step a
                   sb  = step b

step (Mul a b) = dmb, if isJust dmb
               = Just (Mul (fromJust sa) b), if isJust sa
               = Just (Mul a (fromJust sb)), if isJust sb
               = Nothing, otherwise
                 where
                   dmb = deltaMul a b
                   sa  = step a
                   sb  = step b

step (Div a b) = ddb, if isJust ddb
               = Just (Div (fromJust sa) b), if isJust sa
               = Just (Div a (fromJust sb)), if isJust sb
               = Nothing, otherwise
                 where
                   ddb = deltaDiv a b
                   sa  = step a
                   sb  = step b


|| Variables and numerals are irreducible
step (Var x) = Nothing
step (Num x) = Nothing

|| ---------- Full normal form (loops if no NF exists) ----------

nf :: term -> term
nf t = nf (fromJust s), if isJust s
     = t, otherwise
        where
            s = step t

|| ===============================
|| Convenience constructors & tests
|| ===============================

|| helper sugar (keep these)
lam x b  = Lam x b
app f a  = App f a
v x      = Var x
plus a b = Add a b
minus a b = Sub a b
times a b = Mul a b
divide a b = Div a b

|| Examples
ex1 = app (lam "x" (plus (v "x") (Num 1))) (Num 41)

ex2 = app (lam "x" (lam "y" (app (v "x") (v "y")))) (v "y")

tru = lam "t" (lam "f" (v "t"))
fls = lam "t" (lam "f" (v "f"))
iff = lam "b" (lam "x" (lam "y" (app (app (v "b") (v "x")) (v "y"))))
ex3 = app (app (app iff tru) (Num 1)) (Num 0)