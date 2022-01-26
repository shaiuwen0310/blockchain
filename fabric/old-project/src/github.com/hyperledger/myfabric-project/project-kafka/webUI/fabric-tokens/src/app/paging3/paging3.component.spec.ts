import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Paging3Component } from './paging3.component';

describe('Paging3Component', () => {
  let component: Paging3Component;
  let fixture: ComponentFixture<Paging3Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Paging3Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Paging3Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
