package X;

import O.O;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class I implements Parcelable {
    public static final Parcelable.Creator<I> CREATOR = new O(8);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2290a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2291b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2292c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int[] f2293d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int[] f2294f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ArrayList f2295m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f2296n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f2297o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f2298p;

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f2290a);
        parcel.writeInt(this.f2291b);
        parcel.writeInt(this.f2292c);
        if (this.f2292c > 0) {
            parcel.writeIntArray(this.f2293d);
        }
        parcel.writeInt(this.e);
        if (this.e > 0) {
            parcel.writeIntArray(this.f2294f);
        }
        parcel.writeInt(this.f2296n ? 1 : 0);
        parcel.writeInt(this.f2297o ? 1 : 0);
        parcel.writeInt(this.f2298p ? 1 : 0);
        parcel.writeList(this.f2295m);
    }
}
