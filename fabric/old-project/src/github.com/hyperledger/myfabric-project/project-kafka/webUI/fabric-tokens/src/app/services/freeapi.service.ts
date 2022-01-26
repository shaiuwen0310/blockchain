import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient, HttpParams }    from '@angular/common/http';

import { invokeTokenURL, queryTokenURL, invokeMemberURL, queryMemberURL, txnURL } from './apiURL';
import { PostTokenREQ }    from '../classes/token';
import { PostMemberREQ }    from '../classes/member';
import { PostTxnREQ } from '../classes/txn';

@Injectable()
export class freeApiService
{
    constructor(private httpClient: HttpClient) {}

    invokeTokenPost(opost:PostTokenREQ): Observable<any> {
        return this.httpClient.post(invokeTokenURL, opost);
    }

    queryTokenPost(opost:PostTokenREQ): Observable<any> {
        return this.httpClient.post(queryTokenURL, opost);
    }

    invokeMemberPost(opost:PostTokenREQ): Observable<any> {
        return this.httpClient.post(invokeMemberURL, opost);
    }

    queryMemberPost(opost:PostMemberREQ): Observable<any> {
        return this.httpClient.post(queryMemberURL, opost);
    }

    invokeTxnPost(opost:PostTxnREQ): Observable<any> {
        return this.httpClient.post(txnURL, opost);
    }

}
