local linalg={}

local vec_mt = {}


function linalg.zero(rows, cols)
  local matrix={}

  if not cols then
    for j=1,rows do
      matrix[j]=0
    end
    return matrix
  end

  for i=1,rows do
    row={}
    for j=1,cols do
      table.insert(row,0)
    end
    table.insert(matrix,row)
  end

  return matrix
end

function linalg.identity(n)


  local matrix=linalg.zero(n,n)

  for i=1,n do
    matrix[i][i]=1
  end

  return matrix
end

function matcopy(A)
  B={}
  if pcall(function ()
    for i=1,#A do
      B[i]={}
      for j=1,#A[1] do
        B[i][j]=A[i][j]
      end
    end
  end) then
  else
    -- this is a vector
    for j=1,#A do
      B[j]=A[j]
    end
  end

  return B
end

function ref(A,b,copy) -- performs gaussian elimination
  local function eliminate(r1, r2, p, i) --eliminates r1 from r2 beginning at the ith element; p is the pivot index
    if #r1~=#r2 then error("malformed matrix",2) end

    local k=r2[p]/r1[p]
    for j=i,#r1 do
      r2[j]=r2[j]-k*r1[j]
    end
  end

  if copy then
    A = matcopy(A)
    b = matcopy(b)
  end

  local row_count = #A
  local col_count = #A[1]

  for i=1,row_count-1 do
    --pivot=i
    if A[i][i]==0 then
      --search for the following for the greatest pivot in absolute value
      g=i

      for k=i+1,row_count do
        if math.abs(A[k][i]) > math.abs(A[g][g]) then
          g=i
        end
      end
      if A[g][g]==0 then return end
      A[i],A[g]=A[g],A[i] --swapping rows
    end

    --eliminating following rows
    for k=i+1,row_count do
      if b then b[k] = b[k] - (A[k][i]/A[i][i])*b[i] end
      eliminate(A[i], A[k], i, i)
    end
  end

  return A,b
end

function backsub(A,b)
  --performs back substitution on a row-echelon form matrix
  if #A~=#A[1] then error("not a square matrix",2) end

  local x=linalg.zero(#A)

  for i=#A,1,-1 do
    local sum=b[i]
    for j=i+1,#A do
      sum = sum - A[i][j]*x[j]
    end
    sum=sum/A[i][i]
    x[i]=sum
  end

  return x
end

function linalg.solve(A,b,copy)
  U,Lb = ref(A,b,copy)
  return backsub(U,Lb)
end

function linalg.tostring(A)
  local str=""

  if pcall(function()
    for i=1,#A do
      str=str.."[ "
      for j=1,#A[1] do
        str=str..A[i][j].." "
      end
      str=str.."]\n"
    end
  end) then
  else
    str="[ "
    for i=1,#A do
      str=str..A[i].." "
    end
    return str.."]"
  end

  return str
end

return linalg
