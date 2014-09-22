import Window
import Set

-- ♭ 𝄫 ♯ 𝄪

currentNotes : Signal (Set.Set String)
currentNotes = constant (Set.fromList ["C", "E"])

notes =
  [ [ "D", "G", "C", "F", "B♭", "E♭", "A♭", "D♭" ]
  , [ "B", "E", "A", "D", "G", "C", "F" ]
  , [ "A♭", "D♭", "G♭", "B", "E", "A", "D" ]
  , [ "F", "B♭", "E♭", "A♭", "D♭", "G♭" ]
  ]
hexRadius = 50
hexDistance = (sqrt 3)*hexRadius

acc : (s -> s) -> (s -> a -> b) -> s -> [a] -> [b]
acc stateFn accFn initialS list = (snd (foldl (\next (s, a) -> (stateFn s, accFn s next :: a)) (initialS, []) list))

column currentNotes x notes = (concat (acc (\y -> y-hexDistance) (\y note -> cell note (x * hexRadius*1.5, y - hexDistance*x/2) (Set.member note currentNotes)) (hexDistance*4) notes))

draw w h currentNotes = collage w h
  (concat (acc (\x -> x+1) (column currentNotes) 0 notes))

cell : String -> (Float, Float) -> Bool -> [Form]
cell note pos sel =
  [ move pos ((filled (if sel then yellow else orange)) (ngon 6 hexRadius))
  , move pos (outlined (solid charcoal) (ngon 6 hexRadius))
  , move pos (toForm ((if sel then centered (bold (toText note)) else plainText note)))
  ]


main = lift3 draw Window.width Window.height currentNotes
-- main = asText (snd (foldr (\note (x, acc) -> (x+173, (x, note) :: acc)) (-173,[]) notes))
