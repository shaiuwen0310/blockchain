import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = '權証操作介面';  
  navLinks: any[];
  activeLinkIndex = -1;

  constructor(private router: Router) {
    this.navLinks = [
      { label: '權証', link: './token', index: 0 },
      { label: '會員', link: './member', index: 1 },
      { label: '交易', link: './transfer', index: 2 },
      { label: '權証查詢', link: './querytoken', index: 3 },
      { label: '會員查詢', link: './querymember', index: 4 }
    ];
  }
  ngOnInit(): void {
    this.router.events.subscribe((res) => {
        this.activeLinkIndex = this.navLinks.indexOf(this.navLinks.find(tab => tab.link === '.' + this.router.url));
    });
  }

}