local bin = require("bin")
bmp = {}
bmp.__index = bin
bmp.width = 0
bmp.height = 0
bmp.Type = "BMP"
local File_Header_Size	= 14
local Image_Header_Size	= 40
--[[
File Header:
bfType		2	The characters "BM"
bfSize		4	The size of the file in bytes
bfReserved1	2	Unused - must be zero
bfReserved2	2	Unused - must be zero
bfOffBits	4	Offset to start of Pixel Data

The Image Header:
biSize			4	Header Size - Must be at least 40
biWidth			4	Image width in pixels
biHeight		4	Image height in pixels
biPlanes		2	Must be 1
biBitCount		2	Bits per pixel - 1, 4, 8, 16, 24, or 32
biCompression	4	Compression type (0 = uncompressed)
biSizeImage		4	Image Size - may be zero for uncompressed images
biXPelsPerMeter	4	Preferred resolution in pixels per meter
biYPelsPerMeter	4	Preferred resolution in pixels per meter
biClrUsed		4	Number Color Map entries that are actually used
biClrImportant	4	Number of significant colors


]]
function bmp:new(w,h)
	local c = {}
	setmetatable(c,self)
	c.header = bin.newDataBuffer(File_Header_Size,"\0")
	c.fileheader = bin.newDataBuffer(Image_Header_Size,"\0")
end
function bmp:tofile(name)
	--
end
