local Matrix = {}
Matrix.mt = {
  __index = Matrix,

  __add = function(a, b)
    local c = {}

    if a._type == "vector" and b._type == "vector" then
      if #a ~= #b then
        error("cannot add vectors from different vector spaces", 2)
      end

      for n=1, #a do
        c[n] = a[n] + b[n]
      end
    elseif a._type == "matrix" and b._type == "matrix" then
      if #a~=#b or #a[1]~=#b[1] then
        error("matrices with different row/column count")
      end

      local cols = {}

      for n=1, #a do
        local column = a[n]+b[n]

        cols[n] = {}
        for m=1, #column do
          cols[n][m] = column[m]
        end
      end

      return Matrix(cols)
    end

    return Matrix(c)
  end,

  __sub = function(a, b)
    return a+(-1*b)
  end,

  __mul = function(a, b)
    local c = {}

    -- scalar multiplication
    if type(a)=="number" then
      if b._type == "vector" then
        for n=1, #b do
          c[n]=a*b[n]
        end

        return Matrix(c)
      else
        -- matrix
        local cols = {}

        for n=1, #b do
          cols[n] = a*b[n]
        end

        return Matrix(cols)
      end
    elseif type(b)=="number" then
      if a._type == "vector" then
        for n=1, #a do
          c[n]=a[n]*b
        end

        return Matrix(c)
      else
        --matrix
        local cols = {}

        for n=1, #a do
          cols[n] = a[n]*b
        end

        return Matrix(cols)
      end
    end

    -- matrix vec multiplication
    if a._type == "matrix" and b._type == "vector" then
      if #a~=#b then
        error("vector dimension has to be the number of columns in the matrix", 2)
      end

      local sum={}
      for n=1, #a[1] do sum[n]=0 end; sum=Matrix(sum)

      for n=1, #a do
        sum = sum+a[n]*b[n]
      end

      return sum
    -- vec matrix multiplication (mx1 . 1xn)
    elseif a._type == "vector" and b._type == "matrix" then
      if #b[1] ~= 1 then
        error("number of rows in matrix B (".. #b[1].. ") has to match number of columns in vector A (1) ", 2)
      end

      local cols = {}
      for n=1, #b do
        local column={}
        for m=1, #a do
          column[m] = a[m]*b[n][1]
        end
        cols[n] = column
      end

      return Matrix(cols)
    -- matrix matrix multiplication
    elseif a._type == "matrix" and b._type == "matrix" then
      if #a~=#b[1] then
        error("number of columns in matrix A (".. #a ..") has to match number of rows in matrix B (".. #b[1].. ")", 2)
      end

      local columns = {}
      local sum = {}

      for col=1, #b do
        print("test")
        for k=1, #a[1] do sum[k]=0 end; sum=Matrix(sum)

        for n=1, #b[1] do
          sum=sum+a[n]*b[col][n]
        end
        print(sum)

        columns[col] = {}
        for n=1, #sum do
          columns[col][n] = sum[n]
        end
      end

      return Matrix(columns)
    -- dot product
    elseif a._type == "vector" and b._type == "vector" then
      if #a~=#b then
        error("cannot dot product vectors from different vector spaces", 2)
      end

      local sum=0

      for n=1, #a do
        sum = sum+a[n]*b[n]
      end

      return sum
    end
  end,
}

-- still to implement:
-- isLinearlyIndependent()
-- isInvertible()
-- invert()

setmetatable(Matrix, {
  __call = function(t, ...)
    local args = {...}
    local o = {}

    if #args == 0 then
      error("null vector", 2)
    end

    if type(args[1]) == "table" and #args==1 then
      args = args[1]
    end

    local size

    if type(args[1]) == "table" then
      o._type = "matrix"

      size = #args[1]
    else
      o._type = "vector"
    end


    for n=1, #args do
      if o._type=="matrix" then
        o[n] = Matrix(args[n])

        if #args[n] ~= size then
          error("malformed matrix", 2)
        end
      else
        o[n] = args[n]
      end
    end

    return setmetatable(o, Matrix.mt)
  end
})

function Matrix.cross(v, u)
  if not (v._type=="vector" and u._type=="vector") then
    error("cross product has to be between two vectors", 2)
  end

  if #v~=3 or #u~=3 then
    error("cross product is only defined for three dimensional vectors", 2)
  end

  local det1 = v[2]*u[3]-v[3]*u[2]
  local det2 = -v[1]*u[3]+v[3]*u[1]
  local det3 = v[1]*u[2]-v[2]*u[1]

  return Matrix(det1, det2, det3)
end

function Matrix.transpose(self)
  if self._type == "vector" then
    error("transposing vectors is not allowed", 2)
  end

  local cols = {}

  for m=1, #self[1] do
    local column = {}
    for n=1, #self do
      column[n] = self[n][m]
    end
    cols[m]=column
  end

  return Matrix(cols)
end

function Matrix.isZero(self)
  if self._type == "vector" then
    for n=1, #self do
      if self[n] ~= 0 then
        return false
      end
    end

    return true
  elseif self._type == "matrix" then
    for n=1, #self do
      for m=1, #self do
        if self[n][m] ~= 0 then
          return false
        end
      end
    end

    return true
  end
end

function Matrix.solve(A, b) -- solve Ax=b for x
  if A._type == "vector" then return; end
  if #A[1] ~= #b then
    error(2)
  end

  A = A:transpose()
  b = Matrix(b)

  print(A:transpose():print() .."\n")

  max_n = math.min(#A, #A[1])
  for n=1,max_n-1 do
    local pivot = A[n][n]

    if pivot == 0 then
      local m = n+1
      for k=n+1,max_n do
        if math.abs(A[k][n]) > math.abs(A[m][n]) then
          m = k
        end
      end
      if A[m][n] ~= 0 then
        A[m],A[n]=A[n],A[m] -- swap columns
        b[m],b[n]=b[n],b[m]

        pivot = A[n][n]
      end
    end
    if pivot ~= 0 then
      for k=n+1,max_n do
        local a = A[k][n]/pivot
        A[k] = A[k] - a*A[n]
      end
    end

    print(A:transpose():print() .."\n")
  end

  local x = {}; for n=1,#b do x[n]=0 end
  for n=#A,1,-1 do

    if A[n]:isZero() and b[n] ~= 0 then
      return -- system is inconsistent
    end

    local sum=0
    for m=#A[n]-1,1,-1 do
      sum = sum + A[n][m]*x[m]
    end
    x[n] = (b[n]-sum)
  end

  return A:transpose()
end

function Matrix.rref(self) -- reduced row echelon form
end

function Matrix.isLinearlyIndependent(...) -- checks if a set of vectors is linearly independent
  local v={...}

  if type(v[1]) == "table" then v=v[1]; end
  if v._type == "matrix" then return true; end

  if #v == 0 then return false; end
  if #v == 1 then return true; end

  local size=#v[1]

  for m=1, #v[1] do
    if #v[1]~=#v[m] then
      error("all vectors have to be in the same vector space", 2)
    end

    for n=2, #v do

    end
  end
end

function Matrix.isInvertible(self)
  if self._type == "vector" then
    return false
  elseif #self~=#self[1] then
    return false
  end
end

function Matrix.invert(self)
  if not self:invertible() then
    return
  end
end

function Matrix.print(self)
  local str = "("
  if self._type == "vector" then
    for n=1, #self do
      if n==#self then
        str = str.. self[n].. ")"
      else
        str = str.. self[n].. ", "
      end
    end
  elseif self._type == "matrix" then
    for m=1, #self[1] do
      for n=1, #self do
        if n==#self then
          str = str.. self[n][m].. ")"
        else
          str = str.. self[n][m].. "\t"
        end
      end
      if m<#self[1] then
        str = str.. "\n("
      end
    end
  end

  return str
end

function Matrix.getType(self)
  return self._type
end

------------------------------------------
-- vector functions

function Matrix:norm(norm)
  if not self._type=="vector" then return end
  if not norm then norm = "euclidean" end

  if norm=="euclidean" then
    local sum=0

    for i=1,#self do
      sum = sum + self[i]^2
    end

    return math.sqrt(sum)
  elseif norm=="max" then
    return math.max(self)
  elseif type(norm)=="number" then
    local sum=0
    local p=norm

    for i=1,#self do
      sum = sum + self[i]^p
    end

    return sum^(1/p)
  end
end

return Matrix
