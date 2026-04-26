package j1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.p002firebaseauthapi.zzags;
import com.google.android.gms.internal.p002firebaseauthapi.zzah;

/* JADX INFO: renamed from: j1.E, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0455E extends AbstractC0458c {
    public static final Parcelable.Creator<C0455E> CREATOR = new C0454D(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5170a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5171b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f5172c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final zzags f5173d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f5174f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f5175m;

    public C0455E(String str, String str2, String str3, zzags zzagsVar, String str4, String str5, String str6) {
        this.f5170a = zzah.zzb(str);
        this.f5171b = str2;
        this.f5172c = str3;
        this.f5173d = zzagsVar;
        this.e = str4;
        this.f5174f = str5;
        this.f5175m = str6;
    }

    public static C0455E d(zzags zzagsVar) {
        com.google.android.gms.common.internal.F.h(zzagsVar, "Must specify a non-null webSignInCredential");
        return new C0455E(null, null, null, zzagsVar, null, null, null);
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return this.f5170a;
    }

    public final AbstractC0458c c() {
        return new C0455E(this.f5170a, this.f5171b, this.f5172c, this.f5173d, this.e, this.f5174f, this.f5175m);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5170a, false);
        AbstractC0184a.i0(parcel, 2, this.f5171b, false);
        AbstractC0184a.i0(parcel, 3, this.f5172c, false);
        AbstractC0184a.h0(parcel, 4, this.f5173d, i4, false);
        AbstractC0184a.i0(parcel, 5, this.e, false);
        AbstractC0184a.i0(parcel, 6, this.f5174f, false);
        AbstractC0184a.i0(parcel, 7, this.f5175m, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
