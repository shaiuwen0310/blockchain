import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { Paging1Component } from './paging1/paging1.component';
import { Paging2Component } from './paging2/paging2.component';
import { Paging3Component } from './paging3/paging3.component';
import { Paging4Component } from './paging4/paging4.component';
import { Paging5Component } from './paging5/paging5.component';

const routes: Routes = [
  { path: '', redirectTo: '/token', pathMatch: 'full' },
  { path: 'token', component: Paging1Component},
  { path: 'member', component: Paging2Component},
  { path: 'transfer', component: Paging3Component},
  { path: 'querytoken', component: Paging4Component},
  { path: 'querymember', component: Paging5Component},
];

export const appRouting = RouterModule.forRoot(routes);

@NgModule({
  imports: [
    RouterModule.forRoot(routes),
    CommonModule
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
