import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Paging1Component } from './paging1.component';

describe('Paging1Component', () => {
  let component: Paging1Component;
  let fixture: ComponentFixture<Paging1Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Paging1Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Paging1Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
