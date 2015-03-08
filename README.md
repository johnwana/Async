# Async

[![Version](http://cocoapod-badges.herokuapp.com/v/async/badge.png)](http://cocoadocs.org/docsets/async)
[![Platform](http://cocoapod-badges.herokuapp.com/p/async/badge.png)](http://cocoadocs.org/docsets/async)

Async is a set of functions for working with asynchronous blocks in Objective-C.

## Getting Started

`Project/AsyncTests.xcodeproj` contains a simple set of tests that demonstrate how to use the library.

## Usage

* Include `Async.h` in your project.
* All Async functions are class-level methods on the Async object.
* Sets of blocks are passed in as an NSArray.
* These blocks always have success and failure callback blocks which conclude the asynchronous function.
* Blocks may additionally receive and return a parameter depending on the method used
* All Async functions have a final `success` and `failure` block. If any one block fails, `failure()` will be called. If not, `succcess()` is called

### Async Functions

* `series`: run a set of blocks in sequential order
* `parallel`: run a set of blocks in parallel
* `eachSeries`: runs a block in series with every item in an array
* `eachParallel`: runs a block in parallel with every item in an array
* `mapParallel`: runs a block in parallel with every item in an array, collecting all the return values
* `mapSeries`: runs a block in series with every item in an array, collecting all the return values
* `repeatUntilSuccess`: repeat a block until it succeeds or maxAttempts is reached
* `waterfall`: run a set of blocks in series, passing the return value of a block to the next block

## Author
 
John Wana, john@wana.us

## License

Async is available under the MIT license. See the LICENSE file for more info.
