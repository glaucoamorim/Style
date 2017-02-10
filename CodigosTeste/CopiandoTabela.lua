function table.copy(t)
  local u = { }
  for k, v in pairs(t) do
    if("table" ~= type(v))then
         u[k] = v 
    else
        u[k] = table.copy(v)
        end
    end
  return u
end

a = {flow = {[1] = {itens = {id = "item1"}}, [2] = {itens = {id = "item2"}}}, grid = {[1] = {itens = {id = "item3"}}}}

b = table.copy(a)

print(b.flow[2].itens.id)

a.flow[1].itens = nil

print(b.flow[1].itens.id)
print(a.flow[1].itens.id)