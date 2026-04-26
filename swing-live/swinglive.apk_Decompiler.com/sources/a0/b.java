package A0;

import android.os.Parcel;

/* JADX INFO: loaded from: classes.dex */
public class b extends RuntimeException {
    public b(String str, Parcel parcel) {
        super(str + " Parcel: pos=" + parcel.dataPosition() + " size=" + parcel.dataSize());
    }
}
