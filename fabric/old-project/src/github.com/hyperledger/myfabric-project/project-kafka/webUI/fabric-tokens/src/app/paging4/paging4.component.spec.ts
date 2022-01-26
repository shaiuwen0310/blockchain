import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Paging4Component } from './paging4.component';

describe('Paging4Component', () => {
  let component: Paging4Component;
  let fixture: ComponentFixture<Paging4Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Paging4Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Paging4Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
