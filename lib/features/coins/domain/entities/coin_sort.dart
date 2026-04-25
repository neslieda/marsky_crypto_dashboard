enum CoinSortBy {
  price('price', 'Price'),
  marketCap('marketCap', 'Market Cap'),
  volume24h('24hVolume', '24h Volume'),
  change('change', '24h Change'),
  listedAt('listedAt', 'Listed Date');

  final String apiValue;
  final String label;
  const CoinSortBy(this.apiValue, this.label);
}

enum CoinSortDirection {
  asc('asc'),
  desc('desc');

  final String apiValue;
  const CoinSortDirection(this.apiValue);
}

enum CoinHistoryPeriod {
  h1('1h', '1H'),
  h24('24h', '24H'),
  d7('7d', '7D'),
  d30('30d', '30D'),
  y1('1y', '1Y');

  final String apiValue;
  final String label;
  const CoinHistoryPeriod(this.apiValue, this.label);
}
