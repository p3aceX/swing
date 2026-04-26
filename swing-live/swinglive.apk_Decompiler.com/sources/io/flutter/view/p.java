package io.flutter.view;

import android.view.View;

/* JADX INFO: loaded from: classes.dex */
public final class p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f4819a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4820b;

    public p(View view, int i4) {
        this.f4819a = view;
        this.f4820b = i4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof p)) {
            return false;
        }
        p pVar = (p) obj;
        return this.f4820b == pVar.f4820b && this.f4819a.equals(pVar.f4819a);
    }

    public final int hashCode() {
        return ((this.f4819a.hashCode() + 31) * 31) + this.f4820b;
    }
}
