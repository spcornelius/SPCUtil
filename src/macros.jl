macro once_then(expr::Expr)
    @assert expr.head == :while
    esc(quote
      $(expr.args[2]) # body of loop
      $expr # loop
    end)
  end
    