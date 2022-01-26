import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Paging5Component } from './paging5.component';

describe('Paging5Component', () => {
  let component: Paging5Component;
  let fixture: ComponentFixture<Paging5Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Paging5Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Paging5Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
