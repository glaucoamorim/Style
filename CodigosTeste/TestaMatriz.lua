media = {}

media[1] = {_attr = "media1", id = "m1"}

media[2] = {_attr = "media2", id = "m2"}

print("teste!!!")

for k,v in ipairs(media) do
	print("teste!!!")
	print("\n")
	print(k)
	print(v.id)
end