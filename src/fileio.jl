using .FileIO

# Most IO backends only support string format
FileIO.File{F}(filepath::SystemPath) where F<:DataFormat = File{F}(convert(String, filepath))
