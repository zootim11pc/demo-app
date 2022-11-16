<?php

use Illuminate\Support\Facades\Route;


Route::get('/', function () {
    return response()
        ->json(request()->header(), 200, [], JSON_PRETTY_PRINT);
});
