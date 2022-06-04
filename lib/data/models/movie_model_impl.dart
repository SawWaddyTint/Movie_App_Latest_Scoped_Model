import 'package:movie_app/data/vos/credit_vo.dart';
import 'package:movie_app/data/vos/genre_vo.dart';
import 'package:movie_app/data/vos/actor_vo.dart';
import 'package:movie_app/data/vos/movie_vo.dart';
import 'package:movie_app/network/movie_data_agent.dart';
import 'package:movie_app/network/retrofit_data_agent_impl.dart';
import 'package:movie_app/persistence/daos/actor_dao.dart';
import 'package:movie_app/persistence/daos/genre_dao.dart';
import 'package:movie_app/persistence/daos/movie_dao.dart';
import 'package:stream_transform/stream_transform.dart';
import 'movie_model.dart';

class MovieModelImpl extends MovieModel {
  MovieDataAgent mDataAgent = RetrofitDataAgentImpl();
  static final MovieModelImpl _singleton = MovieModelImpl._internal();

  factory MovieModelImpl() {
    return _singleton;
  }

  MovieModelImpl._internal() {
    getNowPlayingMoviesFromDatabase();
    getPopularMoviesFromDatabase();
    getTopRatedMoviesFromDatabase();
    getAllActorsFromDatabase();
    getGenresFromDatabase();
    getActors(1);
    getAllActorsFromDatabase();
    getGenres();
    getGenresFromDatabase();
  }
  //Daos

  MovieDao mMovieDao = MovieDao();
  GenreDao mGenreDao = GenreDao();
  ActorDao mActorDao = ActorDao();

  //States
  List<MovieVO> mNowPlayingMovieList;
  List<MovieVO> mPopularMoviesList;
  List<GenreVO> mGenreList;
  List<ActorVO> mActors;
  List<MovieVO> mShowCaseMovieList;
  List<MovieVO> mMoviesByGenreList;
  MovieVO mMovie;
  List<CreditVO> mActorsList;
  List<CreditVO> mCreatorsList;
  // Network
  @override
  void getNowPlayingMovies(int page) {
    mDataAgent.getNowPlayingMovies(page).then((movies) async {
      List<MovieVO> nowPlayingMovies = movies.map((movie) {
        movie.isNowPlaying = true;
        movie.isPopular = false;
        movie.isTopRated = false;
        return movie;
      }).toList();
      mMovieDao.saveMovies(nowPlayingMovies);
      mNowPlayingMovieList = nowPlayingMovies;
      notifyListeners();
    });
  }

  @override
  void getPopularMovies(int page) {
    mDataAgent.getPopularMovies(page).then((movies) async {
      List<MovieVO> popularMovies = movies.map((movie) {
        movie.isNowPlaying = false;
        movie.isPopular = true;
        movie.isTopRated = false;
        return movie;
      }).toList();
      mMovieDao.saveMovies(popularMovies);
      mPopularMoviesList = popularMovies;
      notifyListeners();
      // return Future.value(movies);
    });
  }

  @override
  void getTopRatedMovies(int page) {
    mDataAgent.getTopRatedMovies(page).then((movies) async {
      List<MovieVO> topRatedMovies = movies.map((movie) {
        movie.isNowPlaying = false;
        movie.isPopular = false;
        movie.isTopRated = true;
        return movie;
      }).toList();
      mMovieDao.saveMovies(topRatedMovies);
      mShowCaseMovieList = topRatedMovies;
      notifyListeners();
      // return Future.value(movies);
    });
  }

  @override
  void getActors(int page) {
    mDataAgent.getActors(page).then((actors) async {
      mActorDao.saveAllActors(actors);
      mActors = actors;
      notifyListeners();
      return Future.value(actors);
    });
  }

  @override
  void getGenres() {
    mDataAgent.getGenres().then((genres) async {
      mGenreDao.saveAllGenres(genres);
      mGenreList = genres;
      getMoviesByGenre(genres.first.id);
      notifyListeners();
      return Future.value(genres);
    });
  }

  @override
  void getMoviesByGenre(int genreId) {
    mDataAgent.getMoviesByGenre(genreId).then((movieList) {
      mMoviesByGenreList = movieList;
      notifyListeners();
    });
  }

  @override
  void getCreditByMovie(int movieId) {
    mDataAgent.getCreditByMovie(movieId).then((creditsList) {
      mActorsList = creditsList.where((credit) => credit.isActor()).toList();
      mCreatorsList =
          creditsList.where((credit) => credit.isCreator()).toList();
    });
  }

  @override
  void getMovieDetails(int movieId) {
    mDataAgent.getMovieDetails(movieId).then((movie) async {
      mMovieDao.saveSingleMovie(movie);
      mMovie = movie;
      notifyListeners();
      return Future.value(movie);
    });
  }

// Database
  @override
  void getAllActorsFromDatabase() {
    mActors = mActorDao.getAllActors();
    notifyListeners();
  }

  @override
  void getGenresFromDatabase() {
    mGenreList = mGenreDao.getAllGenres();
    notifyListeners();
  }

  @override
  void getMovieDetailsFromDatabase(int movieId) {
    mMovie = mMovieDao.getMovieById(movieId);
    notifyListeners();
  }

  @override
  void getNowPlayingMoviesFromDatabase() {
    this.getNowPlayingMovies(1);
    mMovieDao
        .getAllMoviesEventStream()
        .startWith(mMovieDao.getNowPlayingMoviesStream())
        .combineLatest(mMovieDao.getNowPlayingMoviesStream(),
            (event, movieList) => movieList as List<MovieVO>)
        .first
        .then((nowPlayingMovies) {
      mNowPlayingMovieList = nowPlayingMovies;
      notifyListeners();
    });
  }

//Reactive Programming

  // Stream<List<MovieVO>> getNowPlayingMoviesFromDatabase() {
  //   this.getNowPlayingMovies(1);
  //   return mMovieDao
  //       .getAllMoviesEventStream()
  //       .startWith(mMovieDao.getNowPlayingMoviesStream())
  //       .map((event) => mMovieDao.getNowPlayingMovies());
  // }

  @override
  void getPopularMoviesFromDatabase() {
    this.getPopularMovies(1);
    mMovieDao
        .getAllMoviesEventStream()
        .startWith(mMovieDao.getPopularMoviesStream())
        .combineLatest(mMovieDao.getPopularMoviesStream(),
            (event, movieList) => movieList as List<MovieVO>)
        .first
        .then((popularMovies) {
      mPopularMoviesList = popularMovies;
    });
  }

  //Reactive Programming

  // @override
  // Stream<List<MovieVO>> getPopularMoviesFromDatabase() {
  //   this.getPopularMovies(1);
  //   return mMovieDao
  //       .getAllMoviesEventStream()
  //       .startWith(mMovieDao.getPopularMoviesStream())
  //       .map((event) => mMovieDao.getPopularMovies());
  // }

  @override
  void getTopRatedMoviesFromDatabase() {
    this.getTopRatedMovies(1);
    mMovieDao
        .getAllMoviesEventStream()
        .startWith(mMovieDao.getTopRatedMoviesStream())
        .combineLatest(mMovieDao.getTopRatedMoviesStream(),
            (event, movieList) => movieList as List<MovieVO>)
        .first
        .then((topRatedMovies) {
      mShowCaseMovieList = topRatedMovies;
    });
  }

// Reactive Programming
  // @override
  // Stream<List<MovieVO>> getTopRatedMoviesFromDatabase() {
  //   this.getTopRatedMovies(1);
  //   return mMovieDao
  //       .getAllMoviesEventStream()
  //       .startWith(mMovieDao.getTopRatedMoviesStream())
  //       .map((event) => mMovieDao.getTopRatedMovies());
  // }

  // Database

}
