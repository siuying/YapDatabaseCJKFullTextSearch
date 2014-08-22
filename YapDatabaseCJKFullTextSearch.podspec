#
# Be sure to run `pod lib lint YapDatabaseCJKFullTextSearch.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YapDatabaseCJKFullTextSearch"
  s.version          = "0.1.1"
  s.summary          = "A YapDatabase extension that allow full text search for CJK content."
  s.description      = <<-DESC
                       Use SQLite porter stemmer from Mozilla Thunderbird, this extension extend
                       YapDatabaseFullTextSearch to allow indexing and searching for CJK content.
                       DESC
  s.homepage         = "https://github.com/siuying/YapDatabaseCJKFullTextSearch"
  s.license          = 'MIT'
  s.author           = { "Francis Chong" => "francis@ignition.hk" }
  s.source           = { :git => "https://github.com/siuying/YapDatabaseCJKFullTextSearch.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/siuying'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*.*'

  s.dependency 'YapDatabase', '>= 2.4'
  s.dependency 'JRSwizzle'
end
