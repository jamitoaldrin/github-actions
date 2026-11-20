<?php

use Illuminate\Support\Facades\Route;

test('it generates secure URLs when a trusted proxy forwards HTTPS', function () {
    Route::get('/__test/proxy-scheme', fn () => url('/'));

    $response = $this->withServerVariables([
        'HTTP_X_FORWARDED_PROTO' => 'https',
    ])->get('/__test/proxy-scheme');

    $response->assertOk()->assertSee('https://localhost', false);
});
