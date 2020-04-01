class UsbDevice {
  UsbDevice({
      this.manufacturer,
      this.product,
      this.productid,
      this.vendorid,
  });
  final String manufacturer;
  final String product;
  final int vendorid;
  final int productid;
}