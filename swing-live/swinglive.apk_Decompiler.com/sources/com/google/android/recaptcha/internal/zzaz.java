package com.google.android.recaptcha.internal;

import J3.f;
import J3.i;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import e1.k;
import java.util.ArrayList;
import java.util.List;
import x3.AbstractC0728h;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class zzaz extends SQLiteOpenHelper {
    public static final zzax zza = new zzax(null);
    private static final int zzb = zzax.zzb("18.4.0");
    private static zzaz zzc;

    public /* synthetic */ zzaz(Context context, f fVar) {
        super(context, "cesdb", (SQLiteDatabase.CursorFactory) null, zzb);
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public final void onCreate(SQLiteDatabase sQLiteDatabase) {
        sQLiteDatabase.execSQL("CREATE TABLE ce (id INTEGER PRIMARY KEY,ts BIGINT NOT NULL,ss TEXT NOT NULL)");
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public final void onDowngrade(SQLiteDatabase sQLiteDatabase, int i4, int i5) {
        sQLiteDatabase.execSQL("DROP TABLE IF EXISTS ce");
        sQLiteDatabase.execSQL("CREATE TABLE ce (id INTEGER PRIMARY KEY,ts BIGINT NOT NULL,ss TEXT NOT NULL)");
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public final void onUpgrade(SQLiteDatabase sQLiteDatabase, int i4, int i5) {
        sQLiteDatabase.execSQL("DROP TABLE IF EXISTS ce");
        sQLiteDatabase.execSQL("CREATE TABLE ce (id INTEGER PRIMARY KEY,ts BIGINT NOT NULL,ss TEXT NOT NULL)");
    }

    public final int zza(List list) {
        if (list.isEmpty()) {
            return 0;
        }
        return getWritableDatabase().delete("ce", "id IN ".concat(String.valueOf(AbstractC0728h.a0(list, ", ", "(", ")", zzay.zza, 24))), null);
    }

    public final int zzb() {
        Cursor cursorRawQuery = getReadableDatabase().rawQuery("SELECT COUNT(*) FROM ce", null);
        int i4 = -1;
        try {
            if (cursorRawQuery.moveToNext()) {
                i4 = cursorRawQuery.getInt(0);
            }
        } catch (Exception unused) {
        } catch (Throwable th) {
            cursorRawQuery.close();
            throw th;
        }
        cursorRawQuery.close();
        return i4;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v1, types: [java.util.ArrayList] */
    /* JADX WARN: Type inference failed for: r0v2, types: [x3.p] */
    /* JADX WARN: Type inference failed for: r0v4, types: [java.util.List] */
    public final List zzd() {
        Cursor cursorQuery = getReadableDatabase().query("ce", null, null, null, null, null, "ts ASC");
        ?? arrayList = new ArrayList();
        while (cursorQuery.moveToNext()) {
            try {
                try {
                    int i4 = cursorQuery.getInt(cursorQuery.getColumnIndexOrThrow("id"));
                    String string = cursorQuery.getString(cursorQuery.getColumnIndexOrThrow("ss"));
                    long j4 = cursorQuery.getLong(cursorQuery.getColumnIndexOrThrow("ts"));
                    i.b(string);
                    arrayList.add(new zzba(string, j4, i4));
                } catch (Exception unused) {
                    arrayList = p.f6784a;
                }
            } finally {
                cursorQuery.close();
            }
        }
        return arrayList;
    }

    public final boolean zzf(zzba zzbaVar) {
        return zza(k.x(zzbaVar)) == 1;
    }
}
