package j1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: j1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0456a extends A0.a {
    public static final Parcelable.Creator<C0456a> CREATOR = new C0454D(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5181a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5182b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f5183c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f5184d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f5185f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f5186m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final String f5187n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f5188o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final String f5189p;

    public C0456a(String str, String str2, String str3, String str4, boolean z4, String str5, boolean z5, String str6, int i4, String str7) {
        this.f5181a = str;
        this.f5182b = str2;
        this.f5183c = str3;
        this.f5184d = str4;
        this.e = z4;
        this.f5185f = str5;
        this.f5186m = z5;
        this.f5187n = str6;
        this.f5188o = i4;
        this.f5189p = str7;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5181a, false);
        AbstractC0184a.i0(parcel, 2, this.f5182b, false);
        AbstractC0184a.i0(parcel, 3, this.f5183c, false);
        AbstractC0184a.i0(parcel, 4, this.f5184d, false);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.i0(parcel, 6, this.f5185f, false);
        AbstractC0184a.o0(parcel, 7, 4);
        parcel.writeInt(this.f5186m ? 1 : 0);
        AbstractC0184a.i0(parcel, 8, this.f5187n, false);
        int i5 = this.f5188o;
        AbstractC0184a.o0(parcel, 9, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 10, this.f5189p, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
