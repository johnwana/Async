#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "Async"
  s.version      = "0.1.0"
  s.summary      = "Set of functions for working with asynchronous functions"
  s.description  = <<-DESC
                    Asynchronous functions are defined by a set of blocks contained in an NSArray.
                    When a block is finished, it calls success() or failure().

                    Functions include:

                    * series: run a set of blocks in sequential order
                    * parallel: run a set of blocks in parallel
                    * mapParallel: run a set of blocks in parallel, collecting all the return values
                    * mapSeries: run a set of blocks in series, collecting all the return values
                    * repeatUntilSuccess: repeat a block until it succeeds or maxAttempts is reached
                    * waterfall: run a set of blocks in series, passing the return value of a block to the next block

                   DESC
  s.homepage     = "http://github.com/johnwana/Async"
  s.license      = 'MIT'
  s.author       = { "John Wana" => "john@wana.us" }
  s.source       = { :git => "http://github.com/johnwana/Async.git", :tag => "0.1.0" }

  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/Async*.h'
end
