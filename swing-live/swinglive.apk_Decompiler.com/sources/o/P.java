package O;

import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class P implements Parcelable {
    public static final Parcelable.Creator<P> CREATOR = new O(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ArrayList f1262a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ArrayList f1263b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0091b[] f1264c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1265d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ArrayList f1266f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ArrayList f1267m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public ArrayList f1268n;

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeStringList(this.f1262a);
        parcel.writeStringList(this.f1263b);
        parcel.writeTypedArray(this.f1264c, i4);
        parcel.writeInt(this.f1265d);
        parcel.writeString(this.e);
        parcel.writeStringList(this.f1266f);
        parcel.writeTypedList(this.f1267m);
        parcel.writeTypedList(this.f1268n);
    }
}
