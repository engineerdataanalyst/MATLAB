function newWord = pig(word)
  % --------------------------
  % convert words to pig latin
  % --------------------------
  if isconsonant(word(1))
    newWord = lower(word);
    vowelLoc = find(isvowel(newWord),1);    
    newWord = [newWord newWord(1:vowelLoc-1) 'ay'];
    newWord(1:vowelLoc-1) = '';    
  elseif isvowel(word(1))
    newWord = lower(word);
    newWord = [newWord 'yay'];
  else
    newWord = word;
  end  
