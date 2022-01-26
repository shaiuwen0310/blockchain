import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import {MatToolbarModule} from '@angular/material/toolbar';
import {MatTabsModule} from '@angular/material/tabs';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';
import { HttpClientModule }    from '@angular/common/http';

import { freeApiService }    from './services/freeapi.service';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { Paging1Component } from './paging1/paging1.component';
import { Paging2Component } from './paging2/paging2.component';
import { Paging3Component } from './paging3/paging3.component';
import { Paging4Component } from './paging4/paging4.component';
import { Paging5Component } from './paging5/paging5.component';

@NgModule({
  declarations: [
    AppComponent,
    Paging1Component,
    Paging2Component,
    Paging3Component,
    Paging4Component,
    Paging5Component,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    MatToolbarModule,
    MatTabsModule,
    FormsModule,
    HttpClientModule
  ],
  providers: [freeApiService],
  bootstrap: [AppComponent]
})
export class AppModule { }
