import Window
import Set
import WebSocket
import Json
import Debug

-- ♭ 𝄫 ♯ 𝄪

currentNotesJson : Signal String
currentNotesJson = WebSocket.connect "ws://localhost:8001/notes" (constant "connect")

noteFromJson : Json.Value -> String
noteFromJson v = case v of
  Json.String s -> s
  _ -> "" -- TODO: should be Maybe String

notesFromJson : String -> Set.Set String
notesFromJson s = case (Json.fromString (Debug.log "js" s)) of
  Just (Json.Array notes) -> Set.fromList (map noteFromJson notes)
  _ -> Set.empty

currentNotes : Signal (Set.Set String)
currentNotes = lift notesFromJson currentNotesJson

noteName : String -> String
noteName s = case s of
  "a" -> "A"
  "b" -> "B"
  "c" -> "C"
  "d" -> "D"
  "e" -> "E"
  "f" -> "F"
  "g" -> "G"
  "ab" -> "A♭"
  "bb" -> "B♭"
  "cb" -> "C♭"
  "db" -> "D♭"
  "eb" -> "E♭"
  "fb" -> "F♭"
  "gb" -> "G♭"
  "a#" -> "A♯"
  "b#" -> "B♯"
  "c#" -> "C♯"
  "d#" -> "D♯"
  "e#" -> "E♯"
  "f#" -> "F♯"
  "g#" -> "G♯"
  s -> s

notes =
  [ [ "d", "g", "c", "f", "a#", "eb", "g#", "db" ]
  , [ "b", "e", "a", "d", "g", "c", "f" ]
  , [ "g#", "db", "f#", "b", "e", "a", "d" ]
  , [ "f", "a#", "eb", "g#", "db", "f#" ]
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
  , move pos (toForm ((if sel then centered (bold (toText (noteName note))) else plainText (noteName note))))
  ]


main = lift3 draw Window.width Window.height currentNotes
-- main = asText (snd (foldr (\note (x, acc) -> (x+173, (x, note) :: acc)) (-173,[]) notes))
