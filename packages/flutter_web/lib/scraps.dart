
//class BMP332Header {
//  int _width; // NOTE: width must be multiple of 4 as no account is made for bitmap padding
//  int _height;
//
//  Uint8List _bmp;
//  int _totalHeaderSize;
//
//  BMP332Header(this._width, this._height) : assert(_width & 3 == 0) {
//    int baseHeaderSize = 54;
//    _totalHeaderSize = baseHeaderSize + 1024; // base + color map
//    int fileLength = _totalHeaderSize + _width * _height; // header + bitmap
//    _bmp = new Uint8List(fileLength);
//    ByteData bd = _bmp.buffer.asByteData();
//    bd.setUint8(0, 0x42);
//    bd.setUint8(1, 0x4d);
//    bd.setUint32(2, fileLength, Endian.little); // file length
//    bd.setUint32(10, _totalHeaderSize, Endian.little); // start of the bitmap
//    bd.setUint32(14, 40, Endian.little); // info header size
//    bd.setUint32(18, _width, Endian.little);
//    bd.setUint32(22, _height, Endian.little);
//    bd.setUint16(26, 1, Endian.little); // planes
//    bd.setUint32(28, 8, Endian.little); // bpp
//    bd.setUint32(30, 0, Endian.little); // compression
//    bd.setUint32(34, _width * _height, Endian.little); // bitmap size
//    // leave everything else as zero
//
//    // there are 256 possible variations of pixel
//    // build the indexed color map that maps from packed byte to RGBA32
//    // better still, create a lookup table see: http://unwind.se/bgr233/
//    for (int rgb = 0; rgb < 256; rgb++) {
//      int offset = baseHeaderSize + rgb * 4;
//
//      int red = rgb & 0xe0;
//      int green = rgb << 3 & 0xe0;
//      int blue = rgb & 6 & 0xc0;
//
//      bd.setUint8(offset + 3, 255); // A
//      bd.setUint8(offset + 2, red); // R
//      bd.setUint8(offset + 1, green); // G
//      bd.setUint8(offset, blue); // B
//    }
//  }
//
//  /// Insert the provided bitmap after the header and return the whole BMP
//  Uint8List appendBitmap(Uint8List bitmap) {
//    int size = _width * _height;
//    assert(bitmap.length == size);
//    _bmp.setRange(_totalHeaderSize, _totalHeaderSize + size, bitmap);
//    return _bmp;
//  }
//}

//String _scene1 = '''
//{
//"name": "Test Scene 1",
//"background": "Stormy_Sky.jpg",
//
//"objects": [
//  {
//  "type": "Sphere",
//  "name": "Green ball",
//  "pos": [-70.0, -46, -650.0],
//  "radius": 50.0,
//  "material": [0.7, 1.0, 1.0, 50.0, 0.3, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.25, 0.582, 0.273, 0.0]
//    }
//  },
//
//  {
//  "type": "Sphere",
//  "name:": "blue",
//  "pos": [130.0, 34.0, 90.0],
//  "radius": 80.0,
//  "material": [0.7, 1.0, 1.0, 20.0, 0.4, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.210, 0.292, 0.867, 0.0]
//    }
//  },
//
//  {
//  "type": "Sphere",
//  "name": "big orange ball",
//  "pos": [-180.0, 95.0, 90.0],
//  "radius": 100.0,
//  "material": [0.7, 1.0, 0.3, 2.0, 0.2, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.929, 0.454, 0.274, 0.0]
//    }
//  },
//
//  {
//  "type": "Sphere",
//  "name": "little floating ball",
//  "pos": [50.0, 178.0, -166.0],
//  "radius": 20.0,
//  "material": [0.7, 1.0, 0.99, 33.0, 0.0, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.9625, 0.582, 0.272 , 0.0]
//    }
//  },
//
//  {
//  "type": "Plane",
//  "pos": [0, -50, 0],
//  "dir": [0, 1, -0.07],
//  "width":  5000.0,
//  "height":  5000.0,
//  "material": [0.7, 1.0, 0.0, 20.0, 0.2, 0],
//  "texture": {
//    "type": "Image",
//    "name": "bert",
//    "filename": "checkerboard_red.jpg",
//    "scale": [34.0, 74.0]
//    }
//  },
//
//    {
//  "type": "Plane",
//  "pos": [0, 1700, 0],
//  "dir": [0, 1, 0.02],
//  "width":  9200.0,
//  "height":  9200.0,
//  "material": [1.0, 1.0, 0.0, 1.0, 0.0, 1],
//  "texture": {
//    "type": "Image",
//    "name": "space",
//    "filename": "space-sky.jpg",
//    "scale": [9.0, 29.0]
//    }
//  }
//
//],
//
//"lights": [
//{
//  "pos": [500.0, 800.0, -700.0]
//}]
//}''';
//
//String _scene2 = '''
//{
//"name": "Test Scene 2",
//"background": "stormy.png",
//
//"objects": [
//  {
//  "type": "Sphere",
//  "name": "Green ball",
//  "pos": [-70.0, 28, -50.0],
//  "radius": 80.0,
//  "material": [0.8, 1.0, 0.5, 10.0, 0.6, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.25, 0.582, 0.273, 0.0]
//    }
//  },
//  {
//  "type": "Sphere",
//  "name": "Red ball",
//  "pos": [60.0, 22, -350.0],
//  "radius": 99.0,
//  "material": [0.7, 1.0, 1.0, 80.0, 0.2, 0],
//  "texture": {
//    "type": "Basic",
//    "colour": [0.77, 0.282, 0.273, 0.0]
//    }
//  },
//  {
//  "type": "Plane",
//  "pos": [-20, -50, 0],
//  "dir": [0, 1, -0.07],
//  "width":  5000.0,
//  "height":  5000.0,
//  "material": [1.0, 1.0, 0.0, 20.0, 0.0, 0],
//  "texture": {
//    "type": "Image",
//    "name": "bert",
//    "filename": "cobblestone_mossy.png",
//    "scale": [100.0, 200.0]
//    }
//  }
//],
//
//"lights": [
//{
//  "pos": [-120.0, 90.0, -600.0]
//}
//]
//
//}''';

//        Texture texture;
//        final json_texture = o['texture'] as Map<dynamic, dynamic>;
//        switch (json_texture['type'].toString()) {
//          case "Basic":
//            texture = TextureBasic.init(RGB.list(
//                (json_texture['colour'] as List<dynamic>).cast<num>()));
//            break;
//          case "Check":
//            texture = TextureCheck.init(RGB.list(
//                (json_texture['colour1'] as List<dynamic>).cast<num>()),
//                RGB.list(
//                    (json_texture['colour2'] as List<dynamic>).cast<num>()),
//                json_texture['size'] as double);
//            break;
////          case "CheckUV":
////            texture = TextureCheckUV.init(RGB.list(
////                (json_texture['colour1'] as List<dynamic>).cast<num>()),
////                RGB.list(
////                    (json_texture['colour2'] as List<dynamic>).cast<num>()),
////                json_texture['size'] as double);
////            break;
////          case "Image":
////            final scale = (json_texture['scale'] as List<dynamic>).cast<
////                double>();
////            texture = TextureImageUV.init(json_texture['name'].toString(),
////                "scenes/textures/" + json_texture['filename'].toString(),
////                scale[0], scale[1]);
////            break;
//        }


//import 'dart:async';
//import 'image.dart';
//
//class ImageManager
//{
////  static final ImageManager _singleton = ImageManager._init();
//
//  ImageManager();
//  static Map<String, Image> _imgs = {};
//  static Completer<void> _comp;
//
//  static void addImage(String name, String filename) {
//    _imgs[name] = Image(filename);
//  }
//
//  static Future loadAllImages() {
//    _comp = Completer();
//    final waiters = <Future<void>>[];
//    for(final String fn in _imgs.keys) {
//      waiters.add( _imgs[fn].loadImageFile() );
//    }
//
//    Future.wait(waiters).then((_) => _comp.complete(null));
//    return _comp.future;
//  }
//
//  ImageManager._init() {
//    _comp = Completer();
//    _imgs = {};
//  }
//
//  static Image getImage(String n) {
//    return _imgs[n];
//  }
//}

//import 'dart:async';
//import 'dart:html';
//import 'rgb.dart';
//
//class Image
//{
//  final String _filename;
//  ImageData _data;
//  ImageElement _image;
//  CanvasRenderingContext2D _ctx;
//  int _width;
//  int _height;
//
//  Image(this._filename);
//
//  Future<void> loadImageFile() {
//    // Fake/hidden image for background
//    _image = ImageElement();
//    // ignore: unsafe_html
//    _image.src = _filename;
//
//    // Wait for it to load, and return future/completer
//    return _image.onLoad.first.then( (_) {
//      _ctx = CanvasElement(width: _image.width, height: _image.height).context2D;
//      _ctx.drawImage(_image, 0, 0);
//      _data = _ctx.getImageData(0, 0, _image.width, _image.height);
//      print("${_image.width}, ${_image.height}");
//      this._width  = _image.width;
//      this._height = _image.height;
//    } );
//  }
//
//  int get height => _height;
//  int get width => _width;
//
//  RGB getRGBPixel(int x, int y) {
//    // ignore: parameter_assignments
//    x = x.clamp(0, _image.width-1).round();
//    // ignore: parameter_assignments
//    y = y.clamp(0, _image.height-1).round();
//
//    // flip Y
//    // ignore: parameter_assignments
//    y = (y - _height+1).abs();
//
//    final pixel = RGB();
//    final index = (x + y * _image.width) * 4;
//
//    pixel.r = _data.data[index + 0] / 256.0;
//    pixel.g = _data.data[index + 1] / 256.0;
//    pixel.b = _data.data[index + 2] / 256.0;
//    pixel.a = (_data.data[index + 3] - 256).abs() / 256.0;
//    return pixel;
//  }
//
//  double bilinear(num x, num y, int offset) {
//    final percentX = 1.0 - (x - x.floor());
//    final percentY = y - y.floor();
//
//    final top = _data.data[offset + y.ceil() * width * 4 + x.floor() * 4] * percentX + _data.data[offset + y.ceil() * width * 4 + x.ceil() * 4] * (1.0 - percentX);
//    final bottom = _data.data[offset + y.floor() * width * 4 + x.floor() * 4] * percentX + _data.data[offset + y.floor() * width * 4 + x.ceil() * 4] * (1.0 - percentX);
//
//    return (top * percentY + bottom * (1.0 - percentY)).toDouble();
//  }
//}

//import 'dart:html';
//import 'rgb.dart';
//
//// Should be a singleton, but can't be arsed to figure out singletons with constructure parameters
//
//class ImageOut
//{
//  static CanvasRenderingContext2D _context;
//  static ImageData _img_data;
//  int _width;
//  int _height;
//  CanvasElement _ce;
//
//  ImageOut(String canvas_dom_id) {
//    _ce = querySelector(canvas_dom_id) as CanvasElement;
//    _context = _ce.getContext('2d') as CanvasRenderingContext2D;
//    _width = _ce.width;
//    _height = _ce.height;
//
//    _img_data = _context.createImageData(_width, _height);
//  }
//
//  void drawPixel(RGB c, int x, int y) {
//    final index = (x + y * _width) * 4;
//
//    _img_data.data[index + 0] = (c.r * 255).ceil();
//    _img_data.data[index + 1] = (c.g * 255).ceil();
//    _img_data.data[index + 2] = (c.b * 255).ceil();
//    _img_data.data[index + 3] = 255 - ((c.a * 255).ceil());
//  }
//
//  void updateCanvas() {
//    _context.putImageData(_img_data, 0, 0, 0, 0, _width, _height);
//  }
//
//  void clearCanvas() {
//    _context.clearRect(0, 0, _width, _height);
//  }
//
//  int get width => _width;
//  int get height => _height;
//
//  /*drawBGPixel(ImageData bg, int x, int y) {
//    int index = (x + y * width) * 4;
//    // Background image will tile/repeat
//    int bgindex = ((x % bg.width) + (y % bg.height) * bg.width) * 4;
//
//    _img_data.data[index + 0] = bg.data[bgindex + 0];
//    _img_data.data[index + 1] = bg.data[bgindex + 1];
//    _img_data.data[index + 2] = bg.data[bgindex + 2];
//    _img_data.data[index + 3] = bg.data[bgindex + 3];
//  }*/
//
//
//  /*Future clearCanvasBG() {
//    _completer = new Completer();
//    _img_data = _context.createImageData(width, height);
//
//    image = new ImageElement(src: "background.png");
//
//    // I don't really understand this voodoo
//    return image.onLoad.first.then( (_) { drawBackgroundImage(); } );
//  }
//
//  drawBackgroundImage() {
//    _context.drawImage(image, 0, 0);
//    _img_data = _context.getImageData(0, 0, width, height);
//    _completer.complete();
//  }*/
//}
