from PIL import Image
import sys

im = Image.open('/home/lledoux/Pictures/mandel.jpg')
pix = im.load()

print('original size: ', im.size)
new_size = (int(sys.argv[1]), int(sys.argv[2]))
im = im.resize(new_size)
print('new size: ', im.size)

with open(sys.argv[3], "w") as out_file:
    for x in range(im.size[0]):
        for y in range(im.size[1]):
            r, g, b = im.getpixel((x,y))
            r = "{:02x}".format(r)
            g = "{:02x}".format(g)
            b = "{:02x}".format(b)
            pix_str = r + g + b + "\n"
            out_file.write(pix_str) 
