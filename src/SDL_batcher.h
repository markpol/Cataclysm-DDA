#pragma once

#include <SDL.h>

using SDL_Texture_Ptr = std::unique_ptr<SDL_Texture, SDL_Texture_deleter>;
class SDL_Batcher
{
public:
  struct State
  {
    SDL_Texture_Ptr texture;
    std::vector<SDL_Rect> srcrects;
    std::vector<SDL_Rect> dstrects;
    SDL_Rect clip;
  };

  SDL_Batcher();
  ~SDL_Batcher();

  const State& current() const;

  bool append(const SDL_Texture_Ptr tex, const point& pos, SDL_Rect *clip);
  bool append(const SDL_Texture_Ptr tex, const SDL_Rect& srcrect, const SDL_Rect& dstrect, SDL_Rect* clip);
  bool append(const SDL_Texture_Ptr tex, const std::vector<SDL_Rect>& srcrects, const std::vector<SDL_Rect>& dstrects, SDL_Rect* clip);

  void reset();
  bool finish();

  bool active() const;
  void setActive(bool value);

};
