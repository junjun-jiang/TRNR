function BlockSize = GetCurrentBlockSize(imrow,imcol,bb,dd,li,lj)

Lx = ceil((imrow-dd)/(bb-dd)); 
Ly = ceil((imcol-dd)/(bb-dd)); 

if li == Lx && lj == Ly
    BlockSize = [imrow-bb+1 imrow imcol-bb+1 imcol];  
elseif li == Lx
    BlockSize = [imrow-bb+1 imrow ((bb-dd)*lj-(bb-dd-1)) ((bb-dd)*lj+dd)];    
elseif lj == Ly
    BlockSize = [((bb-dd)*li-(bb-dd-1)) ((bb-dd)*li+dd) imcol-bb+1 imcol];    
else
    BlockSize = [((bb-dd)*li-(bb-dd-1)) ((bb-dd)*li+dd) ((bb-dd)*lj-(bb-dd-1)) ((bb-dd)*lj+dd)];        
end