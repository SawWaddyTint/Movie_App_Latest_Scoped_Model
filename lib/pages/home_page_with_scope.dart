import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/models/movie_model_impl.dart';
import 'package:movie_app/data/vos/actor_vo.dart';
import 'package:movie_app/data/vos/genre_vo.dart';
import 'package:movie_app/data/vos/movie_vo.dart';
import 'package:movie_app/pages/movie_details_page_with_scope.dart';
import 'package:movie_app/resources/colors.dart';
import 'package:movie_app/resources/dimen.dart';
import 'package:movie_app/resources/strings.dart';
import 'package:movie_app/viewitems/banner_view.dart';
import 'package:movie_app/viewitems/movie_view.dart';
import 'package:movie_app/viewitems/showcase_view.dart';
import 'package:movie_app/widgets/actors_and_creators_section.dart';
import 'package:movie_app/widgets/see_more_text.dart';

import 'package:movie_app/widgets/title_text.dart';
import 'package:movie_app/widgets/title_text_with_see_more_view.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MovieModelImpl>(
      builder: (BuildContext context, Widget child, MovieModelImpl model) {
        return (model.mNowPlayingMovieList != null &&
                model.mPopularMoviesList != null &&
                model.mGenreList != null &&
                model.mActors != null &&
                model.mShowCaseMovieList != null &&
                model.mMoviesByGenreList != null)
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: PRIMARY_COLOR,
                  title: Text(
                    MAIN_SCREEN_APP_BAR_TITLE,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  leading: Icon(
                    Icons.menu,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: MEDIUM_MARGIN_2,
                      ),
                      child: Icon(Icons.search),
                    ),
                  ],
                ),
                body: Container(
                  color: HOME_SCREEN_BACKGROUND_COLOR,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScopedModelDescendant<MovieModelImpl>(
                          builder: (BuildContext context, Widget child,
                              MovieModelImpl model) {
                            return BannerSectionView(
                              mPopularMovies:
                                  model.mPopularMoviesList.take(8).toList(),
                            );
                          },
                        ),

                        SizedBox(height: MEDIUM_MARGIN),
                        ScopedModelDescendant<MovieModelImpl>(
                          builder: (BuildContext context, Widget child,
                              MovieModelImpl model) {
                            return BestPopularMoviesAndSerialsSectionView(
                                (movieId) => _navigateToMovieDetailsScreen(
                                    context, movieId, model),
                                model.mNowPlayingMovieList);
                          },
                        ),
                        SizedBox(height: LARGE_MARGIN),
                        CheckMovieShowtimesSectionView(),
                        SizedBox(height: LARGE_MARGIN),
                        ScopedModelDescendant<MovieModelImpl>(
                          builder: (BuildContext context, Widget child,
                              MovieModelImpl model) {
                            return GenreSectionView(
                              genreList: model.mGenreList,
                              onTapMovie: (movieId) =>
                                  _navigateToMovieDetailsScreen(
                                      context, movieId, model),
                              onTapGenre: (genreId) =>
                                  model.getMoviesByGenre(genreId),
                              mMoviesByGenreList: model.mMoviesByGenreList,
                            );
                          },
                        ),

                        SizedBox(height: LARGE_MARGIN),
                        // HorizontalMovieListView(),
                        // SizedBox(height: LARGE_MARGIN),
                        ScopedModelDescendant<MovieModelImpl>(
                          builder: (BuildContext context, Widget child,
                              MovieModelImpl model) {
                            return ShowcasesSection(model.mShowCaseMovieList);
                          },
                        ),
                        SizedBox(height: LARGE_MARGIN),
                        ScopedModelDescendant<MovieModelImpl>(
                          builder: (BuildContext context, Widget child,
                              MovieModelImpl model) {
                            return ActorsAndCreatorsSection(
                                ACTORS_TITLE, ACTORS_SEE_MORE,
                                mActorsList: model.mActors);
                          },
                        ),
                        SizedBox(height: LARGE_MARGIN),
                      ],
                    ),
                  ),
                ))
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  void _navigateToMovieDetailsScreen(
      BuildContext context, int movieId, MovieModelImpl model) {
    model.getMovieDetails(movieId);
    model.getMovieDetailsFromDatabase(movieId);
    model.getCreditByMovie(movieId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoviesDetailsPage(),
      ),
    );
  }
}

class CheckMovieShowtimesSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MEDIUM_MARGIN_2),
      height: Showtime_Height,
      color: PRIMARY_COLOR,
      padding: EdgeInsets.all(LARGE_MARGIN),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MAIN_SCREEN_CHECK_MOVIE_SHOWTIMES,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: TEXT_HEADING_1X,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              SeeMoreText(MAIN_SCREEN_SEE_MORE, textColor: PLAY_BUTTON_COLOR),
            ],
          ),
          Spacer(),
          Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: BANNER_PLAY_BUTTON_SIZE,
          ),
        ],
      ),
    );
  }
}

class ShowcasesSection extends StatelessWidget {
  List<MovieVO> mShowCaseMovieList;
  ShowcasesSection(this.mShowCaseMovieList);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MEDIUM_MARGIN_2),
          child: TitleTextWithSeeMoreView(
            SHOWCASE_TITLE,
            SHOWCASE_SEE_MORE,
          ),
        ),
        SizedBox(height: MEDIUM_MARGIN_2),
        Container(
          height: Showcases_Height,
          child: (mShowCaseMovieList != null)
              ? ListView(
                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: MEDIUM_MARGIN_2),
                  children: mShowCaseMovieList
                      .map((showCaseMovie) => ShowcaseView(showCaseMovie))
                      .toList(),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        )
      ],
    );
  }
}

class BestPopularMoviesAndSerialsSectionView extends StatelessWidget {
  final Function(int) onTapMovie;
  final List<MovieVO> mNowPlayingMovieList;
  BestPopularMoviesAndSerialsSectionView(
      this.onTapMovie, this.mNowPlayingMovieList);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: MEDIUM_MARGIN_2),
          child: TitleText(MOVIE_LISTS_TITLE),
        ),
        SizedBox(height: MEDIUM_MARGIN_2),
        HorizontalMovieListView(
          (movieId) {
            onTapMovie(movieId);
          },
          movieList: this.mNowPlayingMovieList,
        ),
      ],
    );
  }
}

class GenreSectionView extends StatelessWidget {
  final List<GenreVO> genreList;
  final List<MovieVO> mMoviesByGenreList;
  final Function(int) onTapMovie;
  final Function(int) onTapGenre;
  // GenreSectionView(this.onTapMovie);

  const GenreSectionView({
    this.genreList,
    this.mMoviesByGenreList,
    this.onTapMovie,
    this.onTapGenre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MEDIUM_MARGIN_2,
          ),
          child: DefaultTabController(
            length: genreList.length,
            child: TabBar(
              onTap: (index) {
                this.onTapGenre(genreList[index].id);
              },
              isScrollable: true,
              indicatorColor: PLAY_BUTTON_COLOR,
              unselectedLabelColor: HOME_SCREEN_LIST_TITLE_COLOR,
              tabs: genreList
                  .map(
                    (genre) => Tab(
                      child: Text(genre.name),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Container(
          color: PRIMARY_COLOR,
          padding: EdgeInsets.only(
            top: MEDIUM_MARGIN_2,
            bottom: LARGE_MARGIN,
          ),
          child: HorizontalMovieListView(
            (movieId) {
              onTapMovie(movieId);
            },
            movieList: mMoviesByGenreList,
          ),
        ),
      ],
    );
  }
}

class HorizontalMovieListView extends StatelessWidget {
  final Function(int) onTapMovie;
  final List<MovieVO> movieList;
  HorizontalMovieListView(this.onTapMovie, {this.movieList});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MOVIE_LIST_HEIGHT,
      child: (movieList != null)
          ? ListView.builder(
              padding: EdgeInsets.only(left: MEDIUM_MARGIN_2),
              scrollDirection: Axis.horizontal,
              itemCount: movieList.length,
              itemBuilder: (BuildContext context, int index) {
                return MovieView(
                  (movieId) {
                    onTapMovie(movieId);
                  },
                  movieList[index],
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class BannerSectionView extends StatefulWidget {
  final List<MovieVO> mPopularMovies;
  BannerSectionView({this.mPopularMovies});
  _BannerSectionViewState createState() => _BannerSectionViewState();
}

class _BannerSectionViewState extends State<BannerSectionView> {
  double _position = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 3.3,
          child: PageView(
            onPageChanged: (page) {
              setState(() {
                _position = page.toDouble();
              });
            },
            children: widget.mPopularMovies
                .map(
                  (popularMovies) => BannerView(
                    mMovie: popularMovies,
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(
          height: MEDIUM_MARGIN_2,
        ),
        DotsIndicator(
          dotsCount: widget.mPopularMovies.length,
          position: _position,
          decorator: DotsDecorator(
            color: HOME_SCREEN_BANNER_DOTS_INACTIVE_COLOR, // Inactive color
            activeColor: PLAY_BUTTON_COLOR,
          ),
        )
      ],
    );
  }
}
