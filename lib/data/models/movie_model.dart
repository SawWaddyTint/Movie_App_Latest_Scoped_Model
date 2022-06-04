import 'package:movie_app/data/vos/actor_vo.dart';
import 'package:movie_app/data/vos/credit_vo.dart';
import 'package:movie_app/data/vos/genre_vo.dart';
import 'package:movie_app/data/vos/movie_vo.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class MovieModel extends Model {
  //Network
  void getNowPlayingMovies(int page);
  void getPopularMovies(int page);
  void getTopRatedMovies(int page);
  void getGenres();
  void getMoviesByGenre(int genreId);
  void getActors(int page);
  void getMovieDetails(int movieId);
  void getCreditByMovie(int movieId);

  //Database
  // Stream<List<MovieVO>> getTopRatedMoviesFromDatabase();
  void getTopRatedMoviesFromDatabase();
  // Stream<List<MovieVO>> getNowPlayingMoviesFromDatabase();
  void getNowPlayingMoviesFromDatabase();
  // Stream<List<MovieVO>> getPopularMoviesFromDatabase();
  void getPopularMoviesFromDatabase();
  void getGenresFromDatabase();
  void getAllActorsFromDatabase();
  void getMovieDetailsFromDatabase(int movieId);
}
