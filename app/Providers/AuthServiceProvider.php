<?php

namespace App\Providers;

// use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Laravel\Passport\Passport;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        // 'App\Models\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        //Registra las rutas de Passport

        // Se configuran los tiempos de expiración de los tokens
        // Passport::tokensExpireIn(now()->addDays(15));
        // Passport::refreshTokensExpireIn(Carbon::now()->addDays(30));
        // Passport::refreshTokensExpireIn(now()->addDays(30));
    }
}
