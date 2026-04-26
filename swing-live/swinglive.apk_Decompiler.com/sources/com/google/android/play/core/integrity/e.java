package com.google.android.play.core.integrity;

import android.net.Network;

/* JADX INFO: loaded from: classes.dex */
final class e extends IntegrityTokenRequest {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final String f3695a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Long f3696b;

    public /* synthetic */ e(String str, Long l2, Network network, d dVar) {
        this.f3695a = str;
        this.f3696b = l2;
    }

    @Override // com.google.android.play.core.integrity.IntegrityTokenRequest
    public final Network a() {
        return null;
    }

    @Override // com.google.android.play.core.integrity.IntegrityTokenRequest
    public final Long cloudProjectNumber() {
        return this.f3696b;
    }

    public final boolean equals(Object obj) {
        Long l2;
        if (obj == this) {
            return true;
        }
        if (obj instanceof IntegrityTokenRequest) {
            IntegrityTokenRequest integrityTokenRequest = (IntegrityTokenRequest) obj;
            if (this.f3695a.equals(integrityTokenRequest.nonce()) && ((l2 = this.f3696b) != null ? l2.equals(integrityTokenRequest.cloudProjectNumber()) : integrityTokenRequest.cloudProjectNumber() == null)) {
                integrityTokenRequest.a();
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        int iHashCode = this.f3695a.hashCode() ^ 1000003;
        Long l2 = this.f3696b;
        return ((iHashCode * 1000003) ^ (l2 == null ? 0 : l2.hashCode())) * 1000003;
    }

    @Override // com.google.android.play.core.integrity.IntegrityTokenRequest
    public final String nonce() {
        return this.f3695a;
    }

    public final String toString() {
        return "IntegrityTokenRequest{nonce=" + this.f3695a + ", cloudProjectNumber=" + this.f3696b + ", network=null}";
    }
}
