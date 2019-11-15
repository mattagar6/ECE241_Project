import png


r = png.Reader(filename = 'C:/Users/kevin/Desktop/generalCoding/image.png')

width, height, pixels, meta = r.read_flat()

print(meta)
"""
print(len(pixels))
print(print[0])
"""

size = width*height
count = 0

file = open("C:/Users/kevin/Desktop/generalCoding/VerilogRAM.txt","a")

print (size)
print(count)

while (count != size):
    
    R=int(pixels[count*4]/16)
    G=int(pixels[count*4+1]/16)
    B=int(pixels[count*4+2]/16)
    """
    R=round(pixels[count*4]/256)
    G=round(pixels[count*4]/256)
    B=round(pixels[count*4]/256)
"""
    file.write(f'{count:02X}'+" : "f'{R:04b}'+f'{G:04b}'+f'{B:04b}'+";\n")


    count=count+1


"""
while (count != size):
    file.write("8'b"+f'{count:08b}'+": begin \n")
    file.write("address <= address+1; \n")
    file.write("data <= 24'b"+f'{pixels[count*4]:08b}'+f'{pixels[count*4+1]:08b}'+f'{pixels[count*4+2]:08b}'+"; \n")
    file.write("x <= 4'b"+ f'{(count%width):04b}'+";\n")
    file.write("y <= 4'b"+ f'{int(count/width):04b}'+";\n")
    file.write("wren <= 1'b1 ;\n")
    file.write("end \n")
    count = count+1
"""

"""
print(r.asRGBA())
print(r.read())
"""

