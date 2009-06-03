------------------------------------------------------------------------
-- Lists where all elements satisfy a given property
------------------------------------------------------------------------

module Data.List.All where

open import Data.Function
open import Data.List as List hiding (map; all)
open import Data.List.Any using (_∈_; here; there)
open import Data.Product as Prod using (_,_)
open import Relation.Nullary
import Relation.Nullary.Decidable as Dec
open import Relation.Unary using (Pred; _⊆_)
open import Relation.Binary.PropositionalEquality

-- All P xs means that all elements in xs satisfy P.

infixr 5 _∷_

data All {A} (P : A → Set) : List A → Set where
  []  : All P []
  _∷_ : ∀ {x xs} (px : P x) (pxs : All P xs) → All P (x ∷ xs)

head : ∀ {A} {P : A → Set} {x xs} → All P (x ∷ xs) → P x
head (px ∷ pxs) = px

tail : ∀ {A} {P : A → Set} {x xs} → All P (x ∷ xs) → All P xs
tail (px ∷ pxs) = pxs

lookup : ∀ {A} {P : A → Set} {x xs} → x ∈ xs → All P xs → P x
lookup (here refl)  (px ∷ pxs) = px
lookup (there x∈xs) (px ∷ pxs) = lookup x∈xs pxs

gmap : ∀ {A B} {P : A → Set} {Q : B → Set} {f : A → B} →
       P ⊆ Q ∘₀ f → All P ⊆ All Q ∘₀ List.map f
gmap g []         = []
gmap g (px ∷ pxs) = g px ∷ gmap g pxs

map : ∀ {A} {P Q : Pred A} → P ⊆ Q → All P ⊆ All Q
map g []         = []
map g (px ∷ pxs) = g px ∷ map g pxs

all : ∀ {A} {P : A → Set} →
      (∀ x → Dec (P x)) → (xs : List A) → Dec (All P xs)
all p []       = yes []
all p (x ∷ xs) with p x
all p (x ∷ xs) | yes px = Dec.map (_∷_ px , tail) (all p xs)
all p (x ∷ xs) | no ¬px = no (¬px ∘ head)