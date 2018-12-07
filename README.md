#  Sample Code from the TechPulse Presentation: 
# "High-Performance Scrolling on iOS Using Layout Models"


This project helps illustrate a way to achieve high-performance scrolling in UITableView (or UICollectionView - the concepts apply just the same). 

Jerky scrolling is often caused by the expensive work of calculating cell heights and laying out the views in your cells.

We demonstrate two approaches to supporting variable height cells.

The first is using a "sizing cell," which is an approach we commonly see in use. This is an instance of our cell that is never rendered on screen - it is just used as a measuring view. To calculate a height, we set our model object on and call 'sizeThatFits.' 

This is the less-than-optimal solution, and has stuttering scrolling.

The second approach is using 'view models' and 'layout models.' These contain the formatted data to display in our view, along with the size and position of each subview for a given width, and a total required height. We can create these off of the main thread, and cache them. 

This solution performs well, providing 60fps.

The PostsTableViewController is initialized to use either a sizing cell or layout models with the same data so you can compare the performance.

(The cells themselves contain only one subview, which is a 'PostView'. IMO, it's a good idea to create cell contents as a seperate view so it can easily be reused in a collection view cell if ever needed.)

Setting a launch argument in the scheme editor of "LOG_GENERAL" will enable console logging for time to load the vc, dequeue cell time, and height for row time.

A flag in the table view controller code can enable FPS logging using the CADisplayLink method, however this is not completely accurate. A better method is to profile your app in Instruments using the Core Animation instrument.

Images are downloaded from a public API that just serves random images. It's great for demos and development. 

Image prefetching is enabled for the layout model approach only.

## Image Fetcher Controller

There is also an implementation of image fetching that is extremely efficient and performant. We briefly mentioned this in the TechPulse talk, but there was not enough time to go into details. Fetching images in a table view is common, and if not done correctly can result in very poor scrolling.

Some features include:

A memory and disk cache
Decompression of images off of the main thread
Cancelation of downloads
Priority of downloads (useful for prefetching)
Throttling of concurrent downloads
Avoiding duplicate requests for same image
Ability to crop / scale images to a target size after download in a memory efficient way
Metrics reporting
Separate queues for downloads and rendering from disk

## Playground

The included Swift playground demonstrates the Layout Model pattern in an extremely simple way - a view containing only two labels.

## Additional Resources


