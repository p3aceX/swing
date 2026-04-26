package G;

import D2.o;
import android.content.Context;
import android.database.Cursor;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import com.google.crypto.tink.shaded.protobuf.S;
import k.f0;

/* JADX INFO: loaded from: classes.dex */
public abstract class b extends BaseAdapter implements Filterable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f476a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f477b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Cursor f478c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Context f479d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public o f480f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public a f481m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public c f482n;

    public abstract void a(View view, Cursor cursor);

    public void b(Cursor cursor) {
        Cursor cursor2 = this.f478c;
        if (cursor == cursor2) {
            cursor2 = null;
        } else {
            if (cursor2 != null) {
                o oVar = this.f480f;
                if (oVar != null) {
                    cursor2.unregisterContentObserver(oVar);
                }
                a aVar = this.f481m;
                if (aVar != null) {
                    cursor2.unregisterDataSetObserver(aVar);
                }
            }
            this.f478c = cursor;
            if (cursor != null) {
                o oVar2 = this.f480f;
                if (oVar2 != null) {
                    cursor.registerContentObserver(oVar2);
                }
                a aVar2 = this.f481m;
                if (aVar2 != null) {
                    cursor.registerDataSetObserver(aVar2);
                }
                this.e = cursor.getColumnIndexOrThrow("_id");
                this.f476a = true;
                notifyDataSetChanged();
            } else {
                this.e = -1;
                this.f476a = false;
                notifyDataSetInvalidated();
            }
        }
        if (cursor2 != null) {
            cursor2.close();
        }
    }

    public abstract String c(Cursor cursor);

    public abstract View d(ViewGroup viewGroup);

    @Override // android.widget.Adapter
    public final int getCount() {
        Cursor cursor;
        if (!this.f476a || (cursor = this.f478c) == null) {
            return 0;
        }
        return cursor.getCount();
    }

    @Override // android.widget.BaseAdapter, android.widget.SpinnerAdapter
    public View getDropDownView(int i4, View view, ViewGroup viewGroup) {
        if (!this.f476a) {
            return null;
        }
        this.f478c.moveToPosition(i4);
        if (view == null) {
            f0 f0Var = (f0) this;
            view = f0Var.f5360q.inflate(f0Var.f5359p, viewGroup, false);
        }
        a(view, this.f478c);
        return view;
    }

    @Override // android.widget.Filterable
    public final Filter getFilter() {
        if (this.f482n == null) {
            c cVar = new c();
            cVar.f483a = this;
            this.f482n = cVar;
        }
        return this.f482n;
    }

    @Override // android.widget.Adapter
    public final Object getItem(int i4) {
        Cursor cursor;
        if (!this.f476a || (cursor = this.f478c) == null) {
            return null;
        }
        cursor.moveToPosition(i4);
        return this.f478c;
    }

    @Override // android.widget.Adapter
    public final long getItemId(int i4) {
        Cursor cursor;
        if (this.f476a && (cursor = this.f478c) != null && cursor.moveToPosition(i4)) {
            return this.f478c.getLong(this.e);
        }
        return 0L;
    }

    @Override // android.widget.Adapter
    public View getView(int i4, View view, ViewGroup viewGroup) {
        if (!this.f476a) {
            throw new IllegalStateException("this should only be called when the cursor is valid");
        }
        if (!this.f478c.moveToPosition(i4)) {
            throw new IllegalStateException(S.d(i4, "couldn't move cursor to position "));
        }
        if (view == null) {
            view = d(viewGroup);
        }
        a(view, this.f478c);
        return view;
    }
}
