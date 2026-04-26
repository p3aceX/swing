package com.google.android.gms.auth.api.signin.internal;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import w0.C0701c;

/* JADX INFO: loaded from: classes.dex */
public final class SignInConfiguration extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<SignInConfiguration> CREATOR = new C0701c(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f3360a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final GoogleSignInOptions f3361b;

    public SignInConfiguration(String str, GoogleSignInOptions googleSignInOptions) {
        F.d(str);
        this.f3360a = str;
        this.f3361b = googleSignInOptions;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof SignInConfiguration)) {
            return false;
        }
        SignInConfiguration signInConfiguration = (SignInConfiguration) obj;
        if (this.f3360a.equals(signInConfiguration.f3360a)) {
            GoogleSignInOptions googleSignInOptions = signInConfiguration.f3361b;
            GoogleSignInOptions googleSignInOptions2 = this.f3361b;
            if (googleSignInOptions2 == null) {
                if (googleSignInOptions == null) {
                    return true;
                }
            } else if (googleSignInOptions2.equals(googleSignInOptions)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        int i4 = 31 * 1;
        String str = this.f3360a;
        int iHashCode = 31 * (i4 + (str == null ? 0 : str.hashCode()));
        GoogleSignInOptions googleSignInOptions = this.f3361b;
        return iHashCode + (googleSignInOptions != null ? googleSignInOptions.hashCode() : 0);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.f3360a, false);
        AbstractC0184a.h0(parcel, 5, this.f3361b, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
