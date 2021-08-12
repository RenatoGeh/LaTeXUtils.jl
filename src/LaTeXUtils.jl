module LaTeXUtils

using Printf

struct Table
  T::Vector{String}
  M::Matrix

  function Table(T::Vector{String}, M::AbstractArray)::Table
    if M isa Vector
      n, m = length(M), length(M[1])
      data = [M[i][j] for i ∈ 1:n, j ∈ 1:m]
    else data = M end
    display(M)
    return new(T, data)
  end
end
export Table

@inline Base.getindex(T::Table, I::Int...) = getindex(T.M, I...)
@inline Base.setindex!(T::Table, v, K...) = setindex!(T.M, v, K...)

function Base.write(T::Table, path::String; highlight::Bool = true, kwargs...)
  f = open(path, "w")
  n, m = size(T.M)
  write(f, "\\begin{table}\n\\begin{tabular}{" * repeat("l|", m-1) * "l}\n")
  if highlight
    P = [sortperm(T.M[i,:]; kwargs...) for i ∈ 1:n]
    R = Matrix(undef, n, m)
    for i ∈ 1:n, j ∈ 1:m R[i,P[i][j]] = j end
  end
  content = ""
  for i ∈ 1:n
    content *= @sprintf("\\textsc{%s}", T.T[i])
    for j ∈ 1:m
      if R[i,j] == 1 content *= @sprintf(" & \\textbf{%.2f}", T.M[i,j])
      elseif R[i,j] == 2 content *= @sprintf(" & \\underline{%.2f}", T.M[i,j])
      elseif R[i,j] == 3 content *= @sprintf(" & \$|\$%.2f\$|\$", T.M[i,j])
      else content *= @sprintf(" & %.2f", M[i,j]) end
    end
    content *= "\\\\\n"
  end
  write(f, content)
  write(f, "\\end{tabular}\n\\end{table}\n")
  close(f)
end


end # module
