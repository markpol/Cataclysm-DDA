#pragma once

#include "SDL_Batcher.h"

using SDL_Texture_Ptr = std::unique_ptr<SDL_Texture, SDL_Texture_deleter>;
class SDL_Batcher
{
public:
  bool active;
  SDL_Batcher::State* batched;
  SDL_Batcher::State* onwork;
};

bool SDL_Batcher::append(const SDL_Texture_Ptr tex, const point& pos, SDL_Rect* clip )
{
  if( !tex.isValid() )
    return true;

  Rect rclip = clip ? *clip : Rect();
  if( !_d->onwork->texture.isValid() )
  {
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
  }

  bool batched = true;
  bool textureSwitched = (_d->onwork->texture.texture() != pic.texture());
  bool clipSwitched = (_d->onwork->clip != rclip);

  if( textureSwitched || clipSwitched)
  {
    std::swap( _d->batched, _d->onwork );

    reset();
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
    batched = false;
  }

  _d->onwork->srcrects.push_back( pic.originRect() );
  _d->onwork->dstrects.push_back( Rect( pos + Point( pic.offset().x(), -pic.offset().y() ), pic.size() ) );
  return batched;
}

bool SDL_Batcher::append(const Picture& pic, const Rect& srcrect, const Rect& dstRect, Rect *clip )
{
  if( !pic.isValid() )
    return true;

  Rect rclip = clip ? *clip : Rect();
  if( !_d->onwork->texture.isValid() )
  {
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
  }

  bool batched = true;
  bool textureSwitched = _d->onwork->texture.texture() != pic.texture();
  bool clipSwitched = (_d->onwork->clip != rclip);

  if( textureSwitched || clipSwitched)
  {
    std::swap( _d->batched, _d->onwork );

    reset();
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
    batched = false;
  }

  _d->onwork->srcrects.push_back( Rect( pic.originRect().lefttop() + srcrect.lefttop(), srcrect.size() ) );
  _d->onwork->dstrects.push_back( Rect( dstRect.lefttop() + Point( pic.offset().x(), -pic.offset().y() ), dstRect.size() ) );

  return batched;
}

bool SDL_Batcher::append(const Picture &pic, const Rects &srcrects, const Rects &dstrects, Rect *clip)
{
  if( !pic.isValid() )
    return true;

  Rect rclip = clip ? *clip : Rect();
  if( !_d->onwork->texture.isValid() )
  {
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
  }

  bool batched = true;
  bool textureSwitched = _d->onwork->texture.texture() != pic.texture();
  bool clipSwitched = (_d->onwork->clip != rclip);

  if( textureSwitched || clipSwitched)
  {
    std::swap( _d->batched, _d->onwork );

    reset();
    _d->onwork->texture = pic;
    _d->onwork->clip = rclip;
    batched = false;
  }

  _d->onwork->srcrects.insert( _d->onwork->srcrects.end(), srcrects.begin(), srcrects.end() );
  _d->onwork->dstrects.insert( _d->onwork->dstrects.end(), dstrects.begin(), dstrects.end() );

  return batched;
}

void SDL_Batcher::reset()
{
  _d->onwork->texture = Picture();
  _d->onwork->clip = Rect();
  _d->onwork->dstrects.clear();
  _d->onwork->srcrects.clear();
}

bool SDL_Batcher::finish()
{
  if( _d->onwork->srcrects.empty() )
    return false;

  std::swap( _d->batched, _d->onwork );
  reset();
  return true;
}

bool SDL_Batcher::active() const { return _d->active; }

void SDL_Batcher::setActive(bool value) { _d->active = value; }

SDL_Batcher::SDL_Batcher() : _d(new Impl)
{
  _d->active = true;
  _d->batched = new State();
  _d->onwork = new State();
}

SDL_Batcher::~SDL_Batcher()
{
  delete _d->batched;
  delete _d->onwork;
}

const SDL_Batcher::State& SDL_Batcher::current() const
{
  return *_d->batched;
}
