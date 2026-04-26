package X;

import O.O;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class H implements Parcelable {
    public static final Parcelable.Creator<H> CREATOR = new O(7);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2286a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2287b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int[] f2288c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f2289d;

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    public final String toString() {
        return "FullSpanItem{mPosition=" + this.f2286a + ", mGapDir=" + this.f2287b + ", mHasUnwantedGapAfter=" + this.f2289d + ", mGapPerSpan=" + Arrays.toString(this.f2288c) + '}';
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f2286a);
        parcel.writeInt(this.f2287b);
        parcel.writeInt(this.f2289d ? 1 : 0);
        int[] iArr = this.f2288c;
        if (iArr == null || iArr.length <= 0) {
            parcel.writeInt(0);
        } else {
            parcel.writeInt(iArr.length);
            parcel.writeIntArray(this.f2288c);
        }
    }
}
