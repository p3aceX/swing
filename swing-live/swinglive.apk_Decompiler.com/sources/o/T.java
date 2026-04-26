package O;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class T implements Parcelable {
    public static final Parcelable.Creator<T> CREATOR = new O(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1274a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1275b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f1276c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1277d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f1278f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f1279m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final boolean f1280n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final boolean f1281o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final boolean f1282p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final int f1283q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final String f1284r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final int f1285s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final boolean f1286t;

    public T(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        this.f1274a = abstractComponentCallbacksC0109u.getClass().getName();
        this.f1275b = abstractComponentCallbacksC0109u.e;
        this.f1276c = abstractComponentCallbacksC0109u.f1420t;
        this.f1277d = abstractComponentCallbacksC0109u.f1388C;
        this.e = abstractComponentCallbacksC0109u.f1389D;
        this.f1278f = abstractComponentCallbacksC0109u.f1390E;
        this.f1279m = abstractComponentCallbacksC0109u.f1393H;
        this.f1280n = abstractComponentCallbacksC0109u.f1418r;
        this.f1281o = abstractComponentCallbacksC0109u.f1392G;
        this.f1282p = abstractComponentCallbacksC0109u.f1391F;
        this.f1283q = abstractComponentCallbacksC0109u.f1402R.ordinal();
        this.f1284r = abstractComponentCallbacksC0109u.f1414n;
        this.f1285s = abstractComponentCallbacksC0109u.f1415o;
        this.f1286t = abstractComponentCallbacksC0109u.f1397M;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(128);
        sb.append("FragmentState{");
        sb.append(this.f1274a);
        sb.append(" (");
        sb.append(this.f1275b);
        sb.append(")}:");
        if (this.f1276c) {
            sb.append(" fromLayout");
        }
        int i4 = this.e;
        if (i4 != 0) {
            sb.append(" id=0x");
            sb.append(Integer.toHexString(i4));
        }
        String str = this.f1278f;
        if (str != null && !str.isEmpty()) {
            sb.append(" tag=");
            sb.append(str);
        }
        if (this.f1279m) {
            sb.append(" retainInstance");
        }
        if (this.f1280n) {
            sb.append(" removing");
        }
        if (this.f1281o) {
            sb.append(" detached");
        }
        if (this.f1282p) {
            sb.append(" hidden");
        }
        String str2 = this.f1284r;
        if (str2 != null) {
            sb.append(" targetWho=");
            sb.append(str2);
            sb.append(" targetRequestCode=");
            sb.append(this.f1285s);
        }
        if (this.f1286t) {
            sb.append(" userVisibleHint");
        }
        return sb.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f1274a);
        parcel.writeString(this.f1275b);
        parcel.writeInt(this.f1276c ? 1 : 0);
        parcel.writeInt(this.f1277d);
        parcel.writeInt(this.e);
        parcel.writeString(this.f1278f);
        parcel.writeInt(this.f1279m ? 1 : 0);
        parcel.writeInt(this.f1280n ? 1 : 0);
        parcel.writeInt(this.f1281o ? 1 : 0);
        parcel.writeInt(this.f1282p ? 1 : 0);
        parcel.writeInt(this.f1283q);
        parcel.writeString(this.f1284r);
        parcel.writeInt(this.f1285s);
        parcel.writeInt(this.f1286t ? 1 : 0);
    }

    public T(Parcel parcel) {
        this.f1274a = parcel.readString();
        this.f1275b = parcel.readString();
        this.f1276c = parcel.readInt() != 0;
        this.f1277d = parcel.readInt();
        this.e = parcel.readInt();
        this.f1278f = parcel.readString();
        this.f1279m = parcel.readInt() != 0;
        this.f1280n = parcel.readInt() != 0;
        this.f1281o = parcel.readInt() != 0;
        this.f1282p = parcel.readInt() != 0;
        this.f1283q = parcel.readInt();
        this.f1284r = parcel.readString();
        this.f1285s = parcel.readInt();
        this.f1286t = parcel.readInt() != 0;
    }
}
