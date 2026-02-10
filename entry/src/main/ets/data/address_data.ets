
export const allRegions: string[] = [
  '北京市', '上海市', '广州市', '深圳市', '天津市', '重庆市',
  '杭州市', '南京市', '武汉市', '成都市', '西安市', '苏州市',
  '郑州市', '长沙市', '青岛市', '宁波市', '厦门市', '大连市',
  '福州市', '济南市', '合肥市', '南宁市', '昆明市', '贵阳市',
  '太原市', '石家庄市', '哈尔滨市', '长春市', '沈阳市', '南昌市',
  '海口市', '兰州市', '西宁市', '银川市', '呼和浩特市', '乌鲁木齐市',
  '拉萨市', '新密市', '新郑市'
];

export const hotCities: string[] = [
  '北京市', '上海市', '广州市', '深圳市', '杭州市', '成都市'
];

export interface RegionItem {
  id: string;
  value: string;
}
export const generateRegionDataSource = (regions: string[]): RegionItem[] => {
  return regions.map((region, index) => {
    const item: RegionItem = {
      id: `${index}-${region}`,
      value: region
    };
    return item;
  });
};