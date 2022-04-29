module LaTeXUtils

using Printf

mutable struct Table
  T::Vector{String}
  M::Matrix
  D::Vector{String}

  function Table(T::Vector{String}, M::AbstractArray, D::Vector{String})::Table
    if M isa Vector
      n, m = length(M), length(M[1])
      data = [M[i][j] for i ∈ 1:n, j ∈ 1:m]
    else data = M end
    return new(T, data, D)
  end

  function Table(M::AbstractArray)::Table
    n, m = size(M)
    return Table(fill("", m), M, fill("", n))
  end
end
export Table

function pushcolumn!(T::Table, X::AbstractArray, name::String)::Table
  T.M = cat(T.M, X; dims = 2)
  push!(T.T, name)
  return T
end
export pushcolumn!

function pushrow!(T::Table, X::AbstractArray, dname::String)::Table
  T.M = cat(T.M, reshape(X, 1, :); dims = 1)
  push!(T.D, dname)
  return T
end
export pushrow!

@inline Base.copy(T::Table)::Table = Table(copy(T.T), copy(T.M), copy(T.D))
@inline function Base.copy!(dst::Table, src::Table)::Table
  dst.T, dst.M, dst.C = copy(src.T), copy(src.M), copy(src.D)
  return dst
end

@inline function Base.append!(T::Table, S::Table)::Table
  append!(T.T, S.T)
  T.M = cat(T.M, S.M; dims = 2)
  return T
end

@inline Base.getindex(T::Table, I::Int...) = getindex(T.M, I...)
@inline Base.setindex!(T::Table, v, K...) = setindex!(T.M, v, K...)

function ranks(T::Table; kwargs...)::Matrix
  n, m = size(T.M)
  P = [sortperm(T.M[i,:]; kwargs...) for i ∈ 1:n]
  R = Matrix{Int}(undef, n, m)
  for i ∈ 1:n, j ∈ 1:m R[i,P[i][j]] = j end
  return R
end
export ranks

function Base.write(T::Table, path::String; highlight::Bool = true, kwargs...)
  f = open(path, "w")
  n, m = size(T.M)
  write(f, "\\begin{table}\n\\begin{tabular}{" * repeat("l|", m-1) * "l}\n")
  if highlight R = ranks(T; kwargs...) end
  content = ""
  for i ∈ 1:m-1 content *= "\\textbf{\\textsc{$(T.T[i])}} & " end
  content *= "\\textbf{\\textsc{$(T.T[m])}}\\\\\n\\hline\n"
  for i ∈ 1:n
    content *= @sprintf("\\textsc{%s}", T.D[i])
    for j ∈ 1:m
      if highlight && R[i,j] == 1 content *= @sprintf(" & \\textbf{%.2f}", T.M[i,j])
      elseif highlight && R[i,j] == 2 content *= @sprintf(" & \\underline{%.2f}", T.M[i,j])
      elseif highlight && R[i,j] == 3 content *= @sprintf(" & \$|\$%.2f\$|\$", T.M[i,j])
      else content *= @sprintf(" & %.2f", T.M[i,j]) end
    end
    content *= "\\\\\n"
  end
  pr, rr = sortperm(vec(sum(R; dims = 1))), Vector{Int}(undef, m)
  for i ∈ 1:m rr[pr[i]] = i end
  content *= "\\hline\n\\textbf{\\textsc{Rank}} "
  for i ∈ 1:m content *= @sprintf("& %d ", rr[i]) end
  content *= "\\\\\n\\hline\n"
  write(f, content)
  write(f, "\\end{tabular}\n\\end{table}\n")
  close(f)
end


end # module
