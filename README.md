# Combine-NasaMediaSearch

Demo project for the Flock of Swifts meetup at the Eureka Building in Irvine Nov 2, 2019.

This project shows how you can use Combine to declaratively combine 3 inputs: a  stream of search terms from a searchbar, a stream of media types from a segmented and a stream of void from a reshfresh control into a single query stream that emits a loading state.  The loading state is used to back the results of the tableview as well as to show empty, error and loading views.

Note that the service deliberately fails, provides empty results or real results 33% of the time, so that you can see the error, empty, loading and loaded states just by refreshing with a valid query.


